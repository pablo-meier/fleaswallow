open Core

(** Represents a static page. *)
type t

val title : t -> string
val description : t -> string
val fs_path : t -> string
val contents : t -> Omd.t

(** Given an file input, returns a page. *)
val to_page : Files.t -> t
