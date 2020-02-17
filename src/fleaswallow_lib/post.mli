open Core
(** * The bread-and-butter of any blog is a post. This module contains a datatype to create * and
    manipulate posts. **)

type t
(** Represents a Post *)

(** Post bodies either have a split (via the <!-- more --> comment) or not. *)
type post_body =
  | Split of (string list * string list)
  | Whole of string list

val title : t -> string
(** Get the post title. *)

val datetime : t -> Unix.tm
(** Get the posts publish date. *)

val last_modified : t -> int
(** Gets the last time this post's source was modified in the filesystem. *)

val tags : t -> string list
(** Get the tags the post belongs to. *)

val og_image : t -> string option
(** Get the OpenGraph image belonging to the post. *)

val og_description : t -> string option
(** Get the OpenGraph description belonging to the post. *)

val content : t -> post_body
(** Receive the (split or whole) content contained in the post. *)

val input_fs_path : t -> string
(** Get local filesystem path with the location of the input post. *)

val output_fs_path : t -> string
(** Get local filesystem path with the location of the rendered post. *)

val reading_time : t -> int
(** Get the calculated, approximate reading time for the post. *)

val next_post_fs_path : t -> (string * string) option
(** Get required values to link to the next post, if applicable. The first is the title, * the
    second is the filesyste path (used to determine the URL). *)

val prev_post_fs_path : t -> (string * string) option
(** Get required values to link to the previous post, if applicable. The first is the title, * the
    second is the filesyste path (used to determine the URL). *)

val all_content : t -> string list
(** Simplify fetching all the post content *)

val compare_post_dates : t -> t -> int
(** For sorting functions: compares two posts chronologically *)

val make_post : Files.t -> t
(** Given a filename and its contents, return a full-constructed Post object. *)

val form_prev_next_links : t list -> t list
(** Takes a list of posts, and returns them with their next/prev links * pointed at their adjacent
    ones. *)

val post_to_string : t -> string
(** Printable representation of a Post *)
