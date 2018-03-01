open Core

(** A blog model contains everything you need to know to build it. *)
type t


(** Build a blog model from a location on the filesystem. *)
val build_blog_model : string -> t

(** The title of the blog. *)
val title : t -> string

(** Description of the blog. *)
val description : t -> string

(** The author of the blog. *)
val author : t -> string

(** Toplevel URL hosting the blog. *)
val hostname : t -> string

(** Directory to place build artifacts. *)
val build_dir : t -> string

(** Default image to use for OpenGraph if not specified in a post. *)
val default_og_image : t -> string

(** Number of posts to include in a feed. *)
val posts_in_feed : t -> int

(** Map containing all the blog posts, keyed by tag, sorted chronologically. "all" contains all the posts. *)
val posts_by_tag : t -> Post.t list String.Map.t

(** List of static pages to render. *)
val static_pages : t -> Page.t list

(** Jingoo template for Index pages. *)
val index_template : t -> string

(** Jingoo template for Post pages. *)
val post_template : t -> string

(** Jingoo template for the homepage. *)
val homepage_template : t -> string

(** Jingoo template for static pages. *)
val statics_template : t -> string

(** Jingoo template for RSS feeds. *)
val rss_template : t -> string

(** Jingoo template for atom feeds. *)
val atom_template : t -> string
