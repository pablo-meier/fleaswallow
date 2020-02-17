type t

val get_cache : string -> t
(** Retrieves the cache located in the directory of the first param. Creates if necessary. *)

val model_updates : t -> string -> Model.t
(** Returns a model to build, containing only what's necessary for the updates. *)

val last_copy_static : t -> Unix.tm
(** Returns the last time we copied the static directory *)

val update_cache : Model.t -> Unix.tm -> unit
(** Writes the last updated times for any files, as well as the last time we copied static/ *)
