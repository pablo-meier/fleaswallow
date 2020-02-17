open Core
open Unix

(** TODOs:
  * - Hardcoded magic numbers (things can/should be configurable)
  * - Parallelization. *)

let format_date { tm_wday; tm_mon; tm_mday; tm_year; _ } =
  let day_of_week =
    match tm_wday with
    | 0 -> "Sunday"
    | 1 -> "Monday"
    | 2 -> "Tuesday"
    | 3 -> "Wednesday"
    | 4 -> "Thursday"
    | 5 -> "Friday"
    | _ -> "Saturday"
  in
  let month =
    match tm_mon with
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
    | _ -> "December"
  in
  Printf.sprintf "%s, %s %d, %d" day_of_week month tm_mday (tm_year + 1900)


let all_feeds_path = "/feeds/all.atom.xml"

let rss_path_for tag = Filename.concat "feeds" (tag ^ ".rss.xml")

let atom_path_for tag = Filename.concat "feeds" (tag ^ ".atom.xml")

let all_posts model = Map.find_exn (Model.posts_by_tag model) "all"

let is_fresh = function
  | Model.Fresh _ -> true
  | Model.Cached _ -> false


let source_value = function
  | Model.Fresh (x, _) -> x
  | Model.Cached x -> x


let any_fresh lst =
  let num_fresh = List.length @@ List.filter ~f:is_fresh lst in
  num_fresh > 0


let tag_path = function
  | "all" -> "/archives.html"
  | tag -> String.concat ["/tags/"; tag; ".html"]


let tag_url tag = Jg_types.Tobj ["name", Jg_types.Tstr tag; "url", Jg_types.Tstr (tag_path tag)]

let post_uri model fs_path =
  let hostname = Model.hostname model in
  Filename.concat hostname fs_path


let or_string x ~default =
  match x with
  | Some y -> y
  | None -> default


(** I don't fully understand what a URN is or why they look like this, just aiming for compatibility
    with Hendershott's Frog here. *)
let generate_urn url_components =
  List.map ~f:Utils.dasherized url_components |> List.cons "urn" |> String.concat ~sep:":"


let index_post_model model post =
  let title, reading_time = Post.title post, Post.reading_time post in
  let content_md = Post.all_content post in
  let url = Post.output_fs_path post in
  let full_url = Post.output_fs_path post |> post_uri model in
  let id = generate_urn [Model.hostname model; url] in
  let datestring = Post.datetime post |> Utils.format_date_index in
  let publish_date_iso =
    Post.datetime post |> Unix.mktime |> Utils.fst |> ISO8601.Permissive.string_of_datetime
  in
  let description = Post.og_description post |> or_string ~default:(Utils.get_desc content_md) in
  let content = content_md |> Utils.add_newlines |> Utils.cmark_from_string in
  Jg_types.Tobj
    [
      "title", Jg_types.Tstr title;
      "url", Jg_types.Tstr url;
      "datestring", Jg_types.Tstr datestring;
      "description", Jg_types.Tstr description;
      "reading_time", Jg_types.Tint reading_time;
      "content", Jg_types.Tstr content;
      "publish_date_iso", Jg_types.Tstr publish_date_iso;
      "full_url", Jg_types.Tstr full_url;
      "id", Jg_types.Tstr id;
    ]


(* Model for template rendering Indexes or RSS feed *)
let index_model model tag posts =
  let index_title = String.concat [Model.title model; ": "; tag] in
  let author = Model.author model in
  let toplevel_description =
    String.concat ["Posts from "; Model.title model; " tagged as: "; tag]
  in
  let tag_path = tag_path tag in
  let id = generate_urn [Model.hostname model; tag_path] in
  let full_uri = Model.hostname model ^ tag_path in
  let full_atom_uri = String.concat ~sep:"/" [Model.hostname model; atom_path_for tag] in
  let og_image = Model.default_og_image model in
  [
    "index_title", Jg_types.Tstr index_title;
    "author", Jg_types.Tstr author;
    "toplevel_description", Jg_types.Tstr toplevel_description;
    "full_uri", Jg_types.Tstr full_uri;
    "full_atom_uri", Jg_types.Tstr full_atom_uri;
    "id", Jg_types.Tstr id;
    "build_date", Jg_types.Tstr (Utils.current_time_as_iso ());
    "og_image", Jg_types.Tstr og_image;
    "posts", Jg_types.Tlist (List.map ~f:(index_post_model model) posts);
  ]


(** Generates the blog's index and tag pages *)
let generate_index_pages model =
  let () = Logs.info (fun m -> m "Building index pages…") in
  let index_template = Model.index_template model in
  let template_string = source_value index_template in
  let index_page tag posts =
    let post_structs = List.map ~f:source_value posts in
    let models = index_model model tag post_structs in
    Jg_template.from_string ~models template_string
  in
  let has_fresh_posts (_, posts) = any_fresh posts in
  let sources_to_render =
    match is_fresh index_template with
    | true -> Model.posts_by_tag model |> Map.to_alist
    | false -> Model.posts_by_tag model |> Map.to_alist |> List.filter ~f:has_fresh_posts
  in
  sources_to_render |> List.map ~f:(fun (tag, posts) -> tag_path tag, index_page tag posts)


(** Generates the blog's individual post pages **)
let generate_post_pages model =
  let () = Logs.info (fun m -> m "Building post pages…") in
  let today_now = Unix.time () |> Unix.gmtime in
  let is_old x = today_now.tm_year - x.tm_year > 1 in
  let prev_next_url = function
    | None -> Jg_types.Tnull
    | Some (title, path) -> Jg_types.Tobj ["name", Jg_types.Tstr title; "url", Jg_types.Tstr path]
  in
  let make_model post =
    let title, reading_time = Post.title post, Post.reading_time post in
    let content_md = Post.all_content post in
    let description = Post.og_description post |> or_string ~default:(Utils.get_desc content_md) in
    let og_image = Post.og_image post |> or_string ~default:(Model.default_og_image model) in
    let full_uri = Post.output_fs_path post |> post_uri model in
    let tags = Post.tags post |> List.map ~f:tag_url in
    let formatted_date = Post.datetime post |> format_date in
    let is_old = Post.datetime post |> is_old in
    let content = content_md |> Utils.add_newlines |> Utils.cmark_from_string in
    let prev = Post.prev_post_fs_path post in
    let next = Post.next_post_fs_path post in
    let author = Model.author model in
    let keywords_list = Post.tags post |> String.concat ~sep:" " |> ( ^ ) (Model.author model) in
    let rss_feed_uri = all_feeds_path in
    [
      "title", Jg_types.Tstr title;
      "author", Jg_types.Tstr author;
      "keywords_list", Jg_types.Tstr keywords_list;
      "description_abridged", Jg_types.Tstr description;
      "og_description", Jg_types.Tstr description;
      "og_image", Jg_types.Tstr og_image;
      "full_uri", Jg_types.Tstr full_uri;
      "rss_feed_uri", Jg_types.Tstr rss_feed_uri;
      "formatted_date", Jg_types.Tstr formatted_date;
      "tags", Jg_types.Tlist tags;
      "reading_time", Jg_types.Tint reading_time;
      "is_old", Jg_types.Tbool is_old;
      "content", Jg_types.Tstr content;
      "link_to_newer", prev_next_url prev;
      "link_to_older", prev_next_url next;
    ]
  in
  let post_template = Model.post_template model in
  let template_string = source_value post_template in
  let post_page p =
    let models = make_model p in
    Jg_template.from_string ~models template_string
  in
  let sources_to_render =
    match is_fresh post_template with
    | true -> model |> all_posts |> List.map ~f:source_value
    | false -> model |> all_posts |> List.filter ~f:is_fresh |> List.map ~f:source_value
  in
  let () =
    Logs.debug (fun m ->
        m "****POST TEMPLATE IS_FRESH: %s" (string_of_bool (is_fresh post_template)))
  in
  let _ =
    model
    |> all_posts
    |> List.map ~f:(fun post ->
           Logs.debug (fun m ->
               m
                 " title: %s | is fresh: %s"
                 (Post.title (source_value post))
                 (string_of_bool (is_fresh post))))
  in
  let () =
    Logs.debug (fun m ->
        m "Num posts to render: %s" (string_of_int (List.length sources_to_render)))
  in
  let result = sources_to_render |> List.map ~f:(fun x -> Post.output_fs_path x, post_page x) in
  let () = Logs.debug (fun m -> m "Num posts rendered: %s" (string_of_int (List.length result))) in
  result


(** Generates the blog's toplevel homepage *)
let generate_homepage model =
  let () = Logs.info (fun m -> m "Building homepage…") in
  let homepage_model posts =
    let tags =
      model |> Model.posts_by_tag |> Map.to_alist |> List.map ~f:(Fn.compose tag_url Utils.fst)
    in
    [
      "title", Jg_types.Tstr (Model.title model);
      "author", Jg_types.Tstr (Model.author model);
      "description_abridged", Jg_types.Tstr (Model.description model);
      "og_description", Jg_types.Tstr (Model.description model);
      "rss_feed_uri", Jg_types.Tstr all_feeds_path;
      "tags", Jg_types.Tlist tags;
      "full_uri", Jg_types.Tstr (Model.hostname model);
      "og_image", Jg_types.Tstr "https://morepablo.com/pabloface.png";
      "posts", Jg_types.Tlist (List.map ~f:(index_post_model model) posts);
    ]
  in
  let homepage_template = Model.homepage_template model in
  let template_string = source_value homepage_template in
  let render_homepage posts =
    let models = homepage_model posts in
    let contents = Jg_template.from_string ~models template_string in
    ["index.html", contents]
  in
  let the_posts = List.take (all_posts model) 5 in
  match is_fresh homepage_template, any_fresh the_posts with
  | false, false -> []
  | _ -> the_posts |> List.map ~f:source_value |> render_homepage


(** Generates the blog's static pages *)
let generate_statics model =
  let () = Logs.info (fun m -> m "Building static pages…") in
  let statics_template = Model.statics_template model in
  let template_string = source_value statics_template in
  let render_static page =
    let title = Page.title page in
    let description = Page.description page in
    let full_uri = page |> Page.output_fs_path |> post_uri model in
    let content_string = Page.contents page |> Utils.cmark_from_string in
    let models =
      [
        "title", Jg_types.Tstr title;
        "author", Jg_types.Tstr (Model.author model);
        "description_abridged", Jg_types.Tstr description;
        "og_description", Jg_types.Tstr description;
        "rss_feed_uri", Jg_types.Tstr all_feeds_path;
        "full_uri", Jg_types.Tstr full_uri;
        "og_image", Jg_types.Tstr "https://morepablo.com/pabloface.png";
        "content", Jg_types.Tstr content_string;
      ]
    in
    let contents = Jg_template.from_string ~models template_string in
    Page.output_fs_path page, contents
  in
  let sources_to_render =
    match is_fresh statics_template with
    | true -> model |> Model.static_pages |> List.map ~f:source_value
    | false -> model |> Model.static_pages |> List.filter ~f:is_fresh |> List.map ~f:source_value
  in
  sources_to_render |> List.map ~f:render_static


(** Generates the blog's RSS feed. Generate an "all" feed to start, later one for every tag. *)
let generate_rss_feeds model =
  let () = Logs.info (fun m -> m "Building feeds…") in
  let rss_template = Model.rss_template model in
  let atom_template = Model.atom_template model in
  let rss_template_string = source_value rss_template in
  let atom_template_string = source_value atom_template in
  let make_rss_from models = Jg_template.from_string ~models rss_template_string in
  let make_atom_from models = Jg_template.from_string ~models atom_template_string in
  let make_feeds_for (tag, posts) =
    let posts_in_feed = Model.posts_in_feed model in
    let post_structs = List.take posts posts_in_feed in
    match is_fresh rss_template, is_fresh atom_template, any_fresh post_structs with
    | false, false, false -> []
    | _ ->
        let the_posts = List.map ~f:source_value post_structs in
        let rss_filename = rss_path_for tag in
        let atom_filename = atom_path_for tag in
        let models = index_model model tag the_posts in
        [rss_filename, make_rss_from models; atom_filename, make_atom_from models]
  in
  let sources_to_render = Model.posts_by_tag model |> Map.to_alist in
  sources_to_render |> List.map ~f:make_feeds_for |> List.concat


(** Generates the sitemap. *)
let generate_sitemap model =
  let () = Logs.info (fun m -> m "Building sitemap…") in
  let hostname = Model.hostname model in
  let hostname_concatter = Filename.concat hostname in
  let post_uri_getter =
    Base.Fn.compose hostname_concatter @@ Base.Fn.compose Post.output_fs_path source_value
  in
  let page_uri_getter =
    Base.Fn.compose hostname_concatter @@ Base.Fn.compose Page.output_fs_path source_value
  in
  let post_uris = model |> all_posts |> List.map ~f:post_uri_getter in
  let page_uris = model |> Model.static_pages |> List.map ~f:page_uri_getter in
  let tag_paths =
    let tags = model |> Model.posts_by_tag |> Map.keys in
    let rss = tags |> List.map ~f:rss_path_for |> List.map ~f:hostname_concatter in
    let atom = tags |> List.map ~f:atom_path_for |> List.map ~f:hostname_concatter in
    let tag_paths = tags |> List.map ~f:tag_path |> List.map ~f:hostname_concatter in
    List.concat [rss; atom; tag_paths]
  in
  let all_uris = List.concat [[hostname]; post_uris; page_uris; tag_paths] |> Utils.add_newlines in
  ["sitemap.txt", all_uris]


let build model =
  let () = Model.build_dir model |> Unix.mkdir_p in
  let output_funcs =
    [
      generate_post_pages;
      generate_index_pages;
      generate_rss_feeds;
      generate_homepage;
      generate_statics;
      generate_sitemap;
    ]
  in
  let results = List.map ~f:(fun f -> f model) output_funcs |> List.concat in
  let () =
    Logs.debug (fun m ->
        m "Number of files to write to disk: %s" (string_of_int (List.length results)))
  in
  results
