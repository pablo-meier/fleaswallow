open Core

type 'a source =
  | Fresh of 'a * Unix.tm
  | Cached of 'a

type blog_metadata = {
  title: string;
  description: string;
  author: string;
  hostname: string;
  build_dir: string;
  default_og_image: string;
  posts_in_feed: int;
}
(** not exported, a placeholder to read from the separate config file *)

type blog_model = {
  title: string source;
  description: string source;
  author: string source;
  hostname: string source;
  build_dir: string source;
  default_og_image: string source;
  posts_in_feed: int source;
  posts_by_tag: Post.t source list String.Map.t;
  static_pages: Page.t source list;
  index_template: string source;
  post_template: string source;
  homepage_template: string source;
  statics_template: string source;
  rss_template: string source;
  atom_template: string source;
}

type t = blog_model

let source_value = function
  | Fresh (x, _) -> x
  | Cached x -> x


let title { title; _ } = title |> source_value

let description { description; _ } = description |> source_value

let author { author; _ } = author |> source_value

let hostname { hostname; _ } = hostname |> source_value

let build_dir { build_dir; _ } = build_dir |> source_value

let posts_by_tag { posts_by_tag; _ } = posts_by_tag

let static_pages { static_pages; _ } = static_pages

let default_og_image { default_og_image; _ } = default_og_image |> source_value

let posts_in_feed { posts_in_feed; _ } = posts_in_feed |> source_value

let index_template { index_template; _ } = index_template

let post_template { post_template; _ } = post_template

let homepage_template { homepage_template; _ } = homepage_template

let statics_template { statics_template; _ } = statics_template

let rss_template { rss_template; _ } = rss_template

let atom_template { atom_template; _ } = atom_template

let read_config_values path =
  let ini = new Inifiles.inifile path in
  let hostname = ini#getval "general" "hostname" in
  let default_og_image = ini#getval "general" "default_og_image" in
  {
    title = ini#getval "general" "title";
    description = ini#getval "general" "description";
    author = ini#getval "general" "author";
    hostname;
    build_dir = ini#getval "general" "build_dir";
    default_og_image = hostname ^ default_og_image;
    posts_in_feed = int_of_string @@ ini#getval "general" "posts_in_feed";
  }


(* Takes a list of posts and produces a map of each post in list *)
let build_tags_map posts current_time =
  let tag_adder map (post : Post.t) =
    List.fold_left
      ~f:(fun m tag -> Map.add_multi m ~key:tag ~data:(Fresh (post, current_time)))
      ~init:map
      ("all" :: Post.tags post)
  in
  posts |> List.fold_left ~f:tag_adder ~init:String.Map.empty |> Map.map ~f:List.rev


let not_draft post =
  match Post.tags post |> List.find ~f:(String.equal "DRAFT") with
  | Some _ -> false
  | None -> true


let build_blog_model path =
  let template_path file = List.fold_left ~init:path ~f:Filename.concat ["templates"; file] in
  let template_string x =
    template_path x |> Files.file_contents |> Option.value_exn |> Files.contents
  in
  let conf = read_config_values (Filename.concat path "config.ini") in
  let posts =
    Files.file_contents_in_dir (Filename.concat path "posts")
    |> List.map ~f:Post.make_post
    |> List.filter ~f:not_draft
    |> List.sort ~compare:Post.compare_post_dates
    |> Post.form_prev_next_links
  in
  let statics =
    Files.file_contents_in_dir (Filename.concat path "pages") |> List.map ~f:Page.to_page
  in
  let current_time = Unix.gettimeofday () |> Unix.gmtime in
  {
    title = Cached conf.title;
    description = (conf.description, current_time) |> Fresh;
    author = (conf.author, current_time) |> Fresh;
    hostname = (conf.hostname, current_time) |> Fresh;
    build_dir = (conf.build_dir, current_time) |> Fresh;
    default_og_image = (conf.default_og_image, current_time) |> Fresh;
    posts_in_feed = (conf.posts_in_feed, current_time) |> Fresh;
    posts_by_tag = build_tags_map posts current_time;
    static_pages = statics |> List.map ~f:(fun p -> Fresh (p, current_time));
    index_template = (template_string "index-template.tmpl", current_time) |> Fresh;
    post_template = (template_string "post-template.tmpl", current_time) |> Fresh;
    homepage_template = (template_string "homepage.tmpl", current_time) |> Fresh;
    statics_template = (template_string "statics-template.tmpl", current_time) |> Fresh;
    rss_template = (template_string "rss.xml.tmpl", current_time) |> Fresh;
    atom_template = (template_string "atom.xml.tmpl", current_time) |> Fresh;
  }


(* Takes a list of posts and produces a map of each post in list *)
let build_tags_map_cached posts =
  let tag_adder map (post : Post.t source) =
    List.fold_left
      ~f:(fun m tag -> Map.add_multi m ~key:tag ~data:post)
      ~init:map
      ("all" :: Post.tags (source_value post))
  in
  posts |> List.fold_left ~f:tag_adder ~init:String.Map.empty |> Map.map ~f:List.rev


let build_blog_model_cached
    ~config_fresh
    ~index_template_fresh
    ~post_template_fresh
    ~homepage_template_fresh
    ~static_template_fresh
    ~rss_template_fresh
    ~atom_template_fresh
    ~statics
    ~posts
  =
  let template_string x = x |> Files.file_contents |> Option.value_exn |> Files.contents in
  let _, conf_path = config_fresh in
  let conf = read_config_values conf_path in
  let current_time = Unix.gettimeofday () |> Unix.gmtime in
  let config_field x =
    match config_fresh with
    | true, _ -> Fresh (x, current_time)
    | false, _ -> Cached x
  in
  let template_field freshness =
    match freshness with
    | true, template_path -> Fresh (template_string template_path, current_time)
    | false, template_path -> template_string template_path |> Cached
  in
  {
    title = config_field conf.title;
    description = config_field conf.description;
    author = config_field conf.author;
    hostname = config_field conf.hostname;
    build_dir = config_field conf.build_dir;
    default_og_image = config_field conf.default_og_image;
    posts_in_feed = config_field conf.posts_in_feed;
    posts_by_tag = build_tags_map_cached posts;
    static_pages = statics;
    index_template = template_field index_template_fresh;
    post_template = template_field post_template_fresh;
    homepage_template = template_field homepage_template_fresh;
    statics_template = template_field static_template_fresh;
    rss_template = template_field rss_template_fresh;
    atom_template = template_field atom_template_fresh;
  }
