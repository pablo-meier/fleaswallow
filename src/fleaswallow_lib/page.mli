type t
(** Represents a static page. *)

val title : t -> string

val description : t -> string

val fs_path : t -> string

val contents : t -> string

val to_page : Files.t -> t
(** Given an file input, returns a page. *)
