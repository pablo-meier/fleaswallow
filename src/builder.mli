open Core

(** Returns a model of what to build: file locations as the first
 * element, and the contents in the second. *)
val build : Model.t -> (string * string) list
