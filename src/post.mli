(**
 * The bread-and-butter of any blog is a post. This module contains a datatype to create
 * and manipulate posts.
 **)
open Core

(** Represents a Post *)
type t

(** Post bodies either have a split (via the <!-- more --> comment) or not. *)
type post_body = Split of (Omd.t * Omd.t) | Whole of Omd.t

(** Get the post title. *)
val title : t -> string

(** Get the posts publish date. *)
val datetime : t -> Unix.tm

(** Get the tags the post belongs to. *)
val tags : t -> string list

(** Get the OpenGraph image belonging to the post. *)
val og_image : t -> string option

(** Get the OpenGraph description belonging to the post. *)
val og_description : t -> string option

(** Receive the (split or whole) content contained in the post. *)
val content : t -> post_body
  
(** Get local filesystem path with the location of the post. *)
val fs_path : t -> string

(** Get the calculated, approximate reading time for the post. *)
val reading_time : t -> int

(** Get required values to link to the next post, if applicable. The first is the title,
 * the second is the filesyste path (used to determine the URL). *)
val next_post_fs_path : t -> (string * string) option

(** Get required values to link to the previous post, if applicable. The first is the title,
 * the second is the filesyste path (used to determine the URL). *)
val prev_post_fs_path : t -> (string * string) option

(** Simplify fetching all the post content *)
val all_content : t -> Omd.t

(** For sorting functions: compares two posts chronologically *)
val compare_post_dates : t -> t -> int

(** Given a filename and its contents, return a full-constructed Post object. *)
val make_post : Files.t -> t

(** Takes a list of posts, and returns them with their next/prev links
 * pointed at their adjacent ones. *)
val form_prev_next_links : t list -> t list

(** Printable representation of a Post *)
val post_to_string : t -> string
