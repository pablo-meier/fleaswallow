open Core

(** A blog model contains everything you need to know to build it. *)
type t


(** Build a blog model from a location on the filesystem. *)
val build_blog_model : string -> t

val title : t -> string
val description : t -> string
val author : t -> string
val hostname : t -> string
val input_fs_path : t -> string
val build_dir : t -> string
val default_og_image : t -> string
val posts_in_feed : t -> int

(** There's an "all" tag for all posts in order.*)
val posts_by_tag : t -> Post.t list String.Map.t
val static_pages : t -> Page.t list
