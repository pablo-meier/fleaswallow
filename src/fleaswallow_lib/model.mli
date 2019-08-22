open Core

type t
(** A blog model contains everything you need to know to build it. *)

val build_blog_model : string -> t
(** Build a blog model from a location on the filesystem. *)

val title : t -> string
(** The title of the blog. *)

val description : t -> string
(** Description of the blog. *)

val author : t -> string
(** The author of the blog. *)

val hostname : t -> string
(** Toplevel URL hosting the blog. *)

val build_dir : t -> string
(** Directory to place build artifacts. *)

val default_og_image : t -> string
(** Default image to use for OpenGraph if not specified in a post. *)

val posts_in_feed : t -> int
(** Number of posts to include in a feed. *)

val posts_by_tag : t -> Post.t list String.Map.t
(** Map containing all the blog posts, keyed by tag, sorted chronologically.
    "all" contains all the posts. *)

val static_pages : t -> Page.t list
(** List of static pages to render. *)

val index_template : t -> string
(** Jingoo template for Index pages. *)

val post_template : t -> string
(** Jingoo template for Post pages. *)

val homepage_template : t -> string
(** Jingoo template for the homepage. *)

val statics_template : t -> string
(** Jingoo template for static pages. *)

val rss_template : t -> string
(** Jingoo template for RSS feeds. *)

val atom_template : t -> string
(** Jingoo template for atom feeds. *)
