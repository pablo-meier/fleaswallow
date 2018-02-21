open Unix
open Core

open Re2.Std


(** TODOs:
 *
 * hardcode magic numbers
 *
 * Caching
 * Parallelization. *)

let format_date {tm_wday; tm_mon; tm_mday; tm_year; _} = 
  let day_of_week = match tm_wday with
    | 0 -> "Sunday"
    | 1 -> "Monday"
    | 2 -> "Tuesday"
    | 3 -> "Wednesday"
    | 4 -> "Thursday"
    | 5 -> "Friday"
    | _ -> "Saturday" in
  let month = match tm_mon with
    | 0 -> "January"
    | 1 -> "February"
    | 2 -> "March"
    | 3 -> "April"
    | 4 -> "May"
    | 5 -> "June"
    | 6 -> "July"
    | 7 -> "August"
    | 8 -> "September"
    | 9 -> "October"
    | 10 -> "November"
    | _ -> "December" in
  Printf.sprintf "%s, %s %d, %d" day_of_week month tm_mday (tm_year + 1900)


let all_feeds_path = "/feeds/all.atom.xml"

let rss_path_for tag = Filename.concat "feeds" (tag ^ ".rss.xml")
let atom_path_for tag = Filename.concat "feeds" (tag ^ ".atom.xml")

let format_date_index {tm_mon; tm_mday; tm_year; _} =
  Printf.sprintf "%d-%02d-%02d" (tm_year + 1900) (tm_mon + 1) tm_mday


let current_time_as_iso () =
  Unix.gettimeofday () |> ISO8601.Permissive.string_of_datetime


let all_posts model =
  Map.find_exn (Model.posts_by_tag model) "all"


let take num lst = List.take lst num


let template_path model file =
  let input_fs_path = Model.input_fs_path model in
  List.fold_left ~init:input_fs_path ~f:Filename.concat ["templates"; file]


let tag_path tag =
  match tag with
  | "all" -> "/archives.html"
  | _ -> String.concat ["/tags/"; tag; ".html"]


let post_uri model fs_path =
  let hostname = Model.hostname model in
  Filename.concat hostname fs_path


let or_string x ~default = match x with
  | Some y -> y
  | None -> default


(** I don't fully understand what a URN is or why they look like this, just aiming
 * for compatibility with Hendershott's Frog here. *)
let bad_in_urns = Re2.create_exn "[^a-z]+"
let generate_urn url_components =
  let rewrite_bads x = Re2.rewrite_exn bad_in_urns ~template:"-" x in
  List.map ~f:rewrite_bads url_components
  |> List.cons "urn"
  |> String.concat ~sep:":"



let index_post_model model post =
  let (title, reading_time) = (Post.title post, Post.reading_time post) in
  let content_md = Post.all_content post in
  let url = Post.fs_path post in
  let full_url = Post.fs_path post |> (post_uri model) in
  let id = generate_urn [Model.hostname model; url] in
  let datestring = Post.datetime post |> format_date_index in
  let publish_date_iso = Post.datetime post |> Unix.mktime |> Utils.fst |> ISO8601.Permissive.string_of_datetime in
  let description = Post.og_description post |> (or_string ~default:(Utils.get_desc content_md)) in
  let content = content_md |> Omd.to_html in
  Jg_types.Tobj [
    ("title",            Jg_types.Tstr title);
    ("url",              Jg_types.Tstr url);
    ("datestring",       Jg_types.Tstr datestring);
    ("description",      Jg_types.Tstr description);
    ("reading_time",     Jg_types.Tint reading_time);
    ("content",          Jg_types.Tstr content);
    ("publish_date_iso", Jg_types.Tstr publish_date_iso);
    ("full_url",         Jg_types.Tstr full_url);
    ("id",               Jg_types.Tstr id);
  ]


(* Model for template rendering Indexes or RSS feed *)
let index_model model tag posts =
  let index_title = String.concat [Model.title model; ": "; tag] in
  let author = Model.author model in
  let toplevel_description = String.concat ["Posts from "; Model.title model; " tagged as: "; tag] in
  let tag_path = tag_path tag in
  let id = generate_urn [Model.hostname model; tag_path] in
  let full_uri = ((Model.hostname model) ^ tag_path) in
  let full_atom_uri = String.concat ~sep:"/" [Model.hostname model; atom_path_for tag] in
  let og_image = Model.default_og_image model in
  [("index_title",          Jg_types.Tstr index_title);
   ("author",               Jg_types.Tstr author);
   ("toplevel_description", Jg_types.Tstr toplevel_description);
   ("full_uri",             Jg_types.Tstr full_uri);
   ("full_atom_uri",        Jg_types.Tstr full_atom_uri);
   ("id",                   Jg_types.Tstr id);
   ("build_date",           Jg_types.Tstr (current_time_as_iso ()));
   ("og_image",             Jg_types.Tstr og_image);
   ("posts",                Jg_types.Tlist (List.map ~f:(index_post_model model) posts));
  ]


(** Generates the blog's index and tag pages *)
let generate_index_pages blog_model =
  let () = Printf.printf "Building index pages...\n" in
  let template_path = template_path blog_model "index-template.tmpl" in
  let index_page tag posts =
    let models = index_model blog_model tag posts in
    Jg_template.from_file ~models:models template_path
  in
  Model.posts_by_tag blog_model
  |> Map.to_alist
  |> List.map ~f:(fun (tag, posts) -> (tag_path tag, index_page tag posts))


(** Generates the blog's individual post pages
 * *)
let generate_post_pages model =
  let () = Printf.printf "Building post pages...\n" in
  let today_now = Unix.time () |> Unix.gmtime in
  let is_old x = (today_now.tm_year - x.tm_year) > 1 in
  let tag_url tag = Jg_types.Tobj [
      ("name", Jg_types.Tstr tag);
      ("url",  Jg_types.Tstr (tag_path tag))] in

  let prev_next_url = function
    | None -> Jg_types.Tnull
    | Some (title, path) -> Jg_types.Tobj [
        ("name", Jg_types.Tstr title);
        ("url",  Jg_types.Tstr path)] in

  let make_model post =
    let (title, reading_time) = (Post.title post, Post.reading_time post) in
    let content_md = Post.all_content post in
    let description = Post.og_description post |> or_string ~default:(Utils.get_desc content_md) in
    let og_image = Post.og_image post |> or_string ~default:(Model.default_og_image model) in
    let full_uri = Post.fs_path post |> post_uri model in
    let tags = Post.tags post |> List.map ~f:tag_url in
    let formatted_date = Post.datetime post |> format_date in
    let is_old = Post.datetime post |> is_old in
    let content = content_md |> Omd.to_html in
    let prev = Post.prev_post_fs_path post in
    let next = Post.next_post_fs_path post in

    let author = Model.author model in
    let keywords_list = Post.tags post |> String.concat ~sep:" " |> ((^) (Model.author model)) in
    let rss_feed_uri = all_feeds_path in

    [("title",                Jg_types.Tstr title);
     ("author",               Jg_types.Tstr author);
     ("keywords_list",        Jg_types.Tstr keywords_list);
     ("description_abridged", Jg_types.Tstr description);
     ("og_description",       Jg_types.Tstr description);
     ("og_image",             Jg_types.Tstr og_image);
     ("full_uri",             Jg_types.Tstr full_uri);
     ("rss_feed_uri",         Jg_types.Tstr rss_feed_uri);
     ("formatted_date",       Jg_types.Tstr formatted_date);
     ("tags",                 Jg_types.Tlist tags);
     ("reading_time",         Jg_types.Tint reading_time);
     ("is_old",               Jg_types.Tbool is_old);
     ("content",              Jg_types.Tstr content);
     ("link_to_newer",        prev_next_url prev);
     ("link_to_older",        prev_next_url next);
    ]
  in
  let template_path = template_path model "post-template.tmpl" in
  let post_page p =
    let models = make_model p in
    Jg_template.from_file ~models:models template_path
  in
  all_posts model
  |> List.map ~f:(fun x -> (Post.fs_path x, post_page x))


(** Generates the blog's toplevel homepage *)
let generate_homepage model =
  let () = Printf.printf "Building homepage...\n" in
  let homepage_model posts =
    [("title",                Jg_types.Tstr (Model.title model));
     ("author",               Jg_types.Tstr (Model.author model));
     ("description_abridged", Jg_types.Tstr (Model.description model));
     ("og_description",       Jg_types.Tstr (Model.description model));
     ("rss_feed_uri",         Jg_types.Tstr all_feeds_path);
     ("full_uri",             Jg_types.Tstr (Model.hostname model));
     ("og_image",             Jg_types.Tstr "https://morepablo.com/pabloface.png");
     ("posts",                Jg_types.Tlist (List.map ~f:(index_post_model model) posts));
    ]
  in
  let template_path = template_path model "homepage.tmpl" in
  let render_homepage posts =
    let models = homepage_model posts in
    let contents = Jg_template.from_file ~models:models template_path in
    [("index.html", contents)]
  in
  model
  |> all_posts
  |> take 5
  |> render_homepage


(** Generates the blog's static pages *)
let generate_statics model =
  let () = Printf.printf "Building statics...\n" in
  let statics_model page =
    let title = Page.title page in
    let description = Page.description page in
    let full_uri = Page.fs_path page |> post_uri model in
    let contents = Page.contents page |> Omd.to_html in
    [("title",                Jg_types.Tstr title);
     ("author",               Jg_types.Tstr (Model.author model));
     ("description_abridged", Jg_types.Tstr description);
     ("og_description",       Jg_types.Tstr description);
     ("rss_feed_uri",         Jg_types.Tstr all_feeds_path);
     ("full_uri",             Jg_types.Tstr full_uri);
     ("og_image",             Jg_types.Tstr "https://morepablo.com/pabloface.png");
     ("content",              Jg_types.Tstr contents);
    ]
  in
  let template_path = template_path model "statics-template.tmpl" in
  let render_static page =
    let models = statics_model page in
    let base_name =  match (Page.fs_path page |> Filename.basename |> Filename.split_extension) with
      | (filename, _) -> filename ^ ".html" in
    let contents = Jg_template.from_file ~models:models template_path in
    (base_name, contents)
  in
  Model.static_pages model
  |> List.map ~f:render_static


(** Generates the blog's RSS feed. Generate an "all" feed to start,
 * later one for every tag.
 * *)
let generate_rss_feeds model =
  let () = Printf.printf "Building RSS feeds...\n" in
  let rss_template_path = template_path model "rss.xml.tmpl" in
  let atom_template_path = template_path model "atom.xml.tmpl" in
  let make_rss_from models =
    Jg_template.from_file ~models:models rss_template_path
  in
  let make_atom_from models =
    Jg_template.from_file ~models:models atom_template_path
  in
  let make_feeds_for (tag, posts) =
    let rss_filename = rss_path_for tag in
    let atom_filename = atom_path_for tag in
    let models = index_model model tag (List.take posts @@ Model.posts_in_feed model) in
    [(rss_filename, make_rss_from models);
     (atom_filename, make_atom_from models)]
  in
  Model.posts_by_tag model
  |> Map.to_alist
  |> List.map ~f:make_feeds_for
  |> List.concat


(** Generates the sitemap. *)
let generate_sitemap model pairs =
  let () = Printf.printf "Building sitemap...\n" in
  let hostname = Model.hostname model in
  let contents =
    pairs
    |> List.map ~f:Utils.fst
    |> List.map ~f:(Filename.concat hostname)
    |> List.cons hostname
    |> Utils.add_newlines
  in
  ("sitemap.txt", contents)::pairs


let build model =
  let () = Model.build_dir model |> Unix.mkdir_p in
  let output_funcs = [
    generate_index_pages;
    generate_rss_feeds;
    generate_post_pages;
    generate_homepage;
    generate_statics;
  ] in
  List.map ~f:(fun f -> f model) output_funcs
  |> List.concat
  |> (generate_sitemap model)
