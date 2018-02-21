open Core
open Inifiles


(** not exported, just a placeholder to read from the separate config file *)
type blog_metadata = {
  title : string;
  description : string;
  author : string;
  hostname : string;
  build_dir : string;
  default_og_image : string;
  posts_in_feed : int;
}


type blog_model = {
  title : string;
  description : string;
  author : string;
  hostname : string;
  input_fs_path : string;
  build_dir : string;
  default_og_image : string;
  posts_in_feed : int;

  posts_by_tag : Post.t list String.Map.t;
  static_pages : Page.t list;
}

type t = blog_model


let title {title;_ } = title
let description {description;_ } = description
let author {author;_ } = author
let hostname {hostname;_ } = hostname
let input_fs_path {input_fs_path;_ } = input_fs_path
let build_dir {build_dir;_ } = build_dir
let posts_by_tag {posts_by_tag;_ } = posts_by_tag
let static_pages {static_pages;_ } = static_pages
let default_og_image {default_og_image;_ } = default_og_image
let posts_in_feed {posts_in_feed; _} = posts_in_feed


let read_config_values path =
  let ini = new Inifiles.inifile path in
  let hostname = ini#getval "general" "hostname" in
  let default_og_image = ini#getval "general" "default_og_image" in
  {
    title =            ini#getval "general" "title";
    description =      ini#getval "general" "description";
    author =           ini#getval "general" "author";
    hostname =         hostname;
    build_dir =        ini#getval "general" "build_dir";
    default_og_image = hostname ^ default_og_image;
    posts_in_feed =    int_of_string @@ ini#getval "general" "posts_in_feed"
  }


(* Takes a list of posts and produces a map of each post in list
 * *)
let build_tags_map posts =
  let conditional_add k d m = match Map.find m k with
    | None -> Map.add m ~key:k ~data:[d]
    | Some xs -> Map.add m ~key:k ~data:(d::xs) in
  let tag_adder map (post:Post.t) =
    List.fold_left ~f:(fun m tag -> conditional_add tag post m) ~init:map ("all"::(Post.tags post))
  in
  posts
  |> List.fold_left ~f:tag_adder ~init:String.Map.empty
  |> Map.map ~f:List.rev


let no_drafts post =
  match Post.tags post |> List.find ~f:(String.equal "DRAFT") with
  | Some _ -> false
  | None -> true


let build_blog_model path =
  let conf = read_config_values (Filename.concat path "config.ini") in
  let posts = Files.file_contents_in_dir (Filename.concat path "posts")
  |> List.map ~f:Post.make_post
  |> List.filter ~f:no_drafts
  |> List.sort ~cmp:Post.compare_post_dates
  |> Post.form_prev_next_links in
  let statics = Files.file_contents_in_dir (Filename.concat path "pages")
  |> List.map ~f:Page.to_page in
  {
    title = conf.title;
    description = conf.description;
    author = conf.author;
    input_fs_path = path;
    hostname = conf.hostname;
    build_dir = conf.build_dir;
    default_og_image = conf.default_og_image;
    posts_in_feed = conf.posts_in_feed;

    posts_by_tag = build_tags_map posts;
    static_pages = statics;
  }
