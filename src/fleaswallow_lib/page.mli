type t
(** Represents a static page. *)

val title : t -> string

val description : t -> string

val input_fs_path : t -> string

val output_fs_path : t -> string

val contents : t -> string

val to_page : Files.t -> t
(** Given an file input, returns a page. *)
