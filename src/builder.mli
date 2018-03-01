open Core

(** Returns a representation of what to build: file locations as the first
 * element, and the contents of those files in the second. *)
val build : Model.t -> (string * string) list
