open Core

type last_modified_map = int String.Map.t

(* The in-memory representation of a cache is a map from source file (as a
 * string) to last modified time (as an int). Unix.stat
 * returns a _float_ number of seconds since epoch in "last modified time"
 * but we'll truncate it for simplicity; I doubt we'll need sub-second granularity here.
 * *)

type t = last_modified_map

(** The structure of the cachefile itself is dead simple: string on one end, `=`, integer
 * on the other.
 *)
let get_cache directory =
  let inifile_to_cache lines =
    let foldable accum line =
      let split = String.split_on_chars ~on:['='] line in
      let key = split |> List.hd_exn in
      let last_modified = List.nth_exn split 1 |> int_of_string in
      Map.set accum ~key ~data:last_modified
    in
    List.fold_left ~f:foldable ~init:String.Map.empty lines
  in
  let cache_location = Filename.concat directory ".fleaswallow_cache" in
  match cache_location |> Files.check_exists with
  | true ->
      cache_location |> Files.file_contents |> Option.value_exn |> Files.lines |> inifile_to_cache
  | false ->
      let _ = Unix.with_file cache_location ~mode:[O_RDWR; O_CREAT] ~f:(fun _ -> ()) in
      inifile_to_cache []


(*
 * If any of the conf files are fresh, we have to update the entire blog.
 * If any of the templates, we have to rebuild whatever that's a template for.
 * If any of the statics are fresh, we rebuild only that static.
 * If any of the posts are fresh, we rebuild any tags, the index, _maybe_ the homepage,
 * and that post itself.
 * *)
let model_updates cache filepath =
  let current_time = Unix.time () |> Unix.gmtime in
  let is_fresh source =
    match Unix.stat source, Map.find cache source with
    | _, None -> true, source
    | { st_mtime; _ }, Some cache_generated ->
        let mtime_as_int = st_mtime |> int_of_float in
        mtime_as_int > cache_generated, source
  in
  let is_fresh_file file =
    match Files.last_modified file, Map.find cache (Files.name file) with
    | _, None -> true
    | mtime, Some last_modified -> mtime > last_modified
  in
  let statics =
    Files.file_contents_in_dir (Filename.concat filepath "pages")
    |> List.map ~f:(fun file ->
           let page = Page.to_page file in
           match is_fresh_file file with
           | true -> Model.Fresh (page, current_time)
           | false -> Model.Cached page)
  in
  let not_draft post =
    match Post.tags post |> List.find ~f:(String.equal "DRAFT") with
    | Some _ -> false
    | None -> true
  in
  let is_fresh_post p =
    match Post.last_modified p, Map.find cache (Post.input_fs_path p) with
    | _, None -> Model.Fresh (p, current_time)
    | mtime, Some last_modified -> (
        match mtime > last_modified with
        | true -> Model.Fresh (p, current_time)
        | false -> Model.Cached p )
  in
  let posts =
    Files.file_contents_in_dir (Filename.concat filepath "posts")
    |> List.map ~f:Post.make_post
    |> List.filter ~f:not_draft
    |> List.sort ~compare:Post.compare_post_dates
    |> Post.form_prev_next_links
    |> List.map ~f:is_fresh_post
  in
  let template_path file = List.fold_left ~init:filepath ~f:Filename.concat ["templates"; file] in
  let config_fresh = is_fresh "./config.ini" in
  let index_template_fresh = template_path "index-template.tmpl" |> is_fresh in
  let post_template_fresh = template_path "post-template.tmpl" |> is_fresh in
  let homepage_template_fresh = template_path "homepage.tmpl" |> is_fresh in
  let static_template_fresh = template_path "statics-template.tmpl" |> is_fresh in
  let rss_template_fresh = template_path "rss.xml.tmpl" |> is_fresh in
  let atom_template_fresh = template_path "atom.xml.tmpl" |> is_fresh in
  Model.build_blog_model_cached
    ~config_fresh
    ~index_template_fresh
    ~post_template_fresh
    ~homepage_template_fresh
    ~static_template_fresh
    ~rss_template_fresh
    ~atom_template_fresh
    ~statics
    ~posts


let last_copy_static cache =
  match Map.find cache "./static" with
  | None -> Unix.gmtime 0.0
  | Some integer -> Unix.gmtime (float_of_int integer)


let update_cache model static_timestamp =
  let all_posts model = Map.find_exn (Model.posts_by_tag model) "all" in
  let freshen_cache old_cache =
    (* let config_sources = [ Model.title; Model.description; Model.author; Model.hostname;
       Model.build_dir; Model.default_og_image; ] in *)
    let as_int_string timestamp = timestamp |> Unix.timegm |> int_of_float in
    let template_updates =
      [
        Model.index_template, "./templates/index-template.tmpl";
        Model.post_template, "./templates/post-template.tmpl";
        Model.homepage_template, "./templates/homepage.tmpl";
        Model.statics_template, "./templates/statics-template.tmpl";
        Model.rss_template, "./templates/rss.xml.tmpl";
        Model.atom_template, "./templates/atom.xml.tmpl";
      ]
    in
    let with_template_updates =
      List.fold_left
        ~f:(fun old (func, str) ->
          match func model with
          | Model.Cached _ -> old
          | Model.Fresh (_, timestamp) -> Map.set old ~key:str ~data:(as_int_string timestamp))
        ~init:old_cache
        template_updates
    in
    let with_static_updates =
      List.fold_left
        ~f:(fun old p ->
          match p with
          | Model.Cached _ -> old
          | Model.Fresh (page, timestamp) ->
              Map.set old ~key:(Page.input_fs_path page) ~data:(as_int_string timestamp))
        ~init:with_template_updates
        (Model.static_pages model)
    in
    let with_post_updates =
      List.fold_left
        ~f:(fun old p ->
          match p with
          | Model.Cached _ -> old
          | Model.Fresh (post, timestamp) ->
              Map.set old ~key:(Post.input_fs_path post) ~data:(as_int_string timestamp))
        ~init:with_static_updates
        (all_posts model)
    in
    let with_statics =
      Map.set with_post_updates ~key:"./static" ~data:(int_of_float (Unix.timegm static_timestamp))
    in
    with_statics
  in
  let persist_cache c =
    let contents =
      c
      |> Map.to_alist
      |> List.map ~f:(fun (post_name, time) -> post_name ^ "=" ^ string_of_int time)
      |> Utils.add_newlines
    in
    Files.write_out_to_file "." (".fleaswallow_cache", contents)
  in
  let old_cache = get_cache "." in
  let updated = freshen_cache old_cache in
  persist_cache updated
