(** The Files modules serves as something of an "imperative shell"
 * layer in the app - we do effectful operations here to return values
 * that other modules can use amongst themselves without having to
 * deal with filesystem mess. *)
open Core

(** Type representing a file's contents and its path in the filesystem. *)
type t


(** Returns a t for every file in the directory that matches our whitelist for filetypes, which
 * are currently `.md` and `.html`. Not recursive. *)
val file_contents_in_dir : string -> t list

(** Creates a record containing the contents of a single file. Returns None if file doesn't
 * exist. *)
val file_contents : string -> t option


(** Name of the input file *)
val name : t -> string
(** File contents as a string list *)
val lines : t -> string list
(** File contents as one fat string. *)
val contents : t -> string


(** Write out a file to the disk: the first value is the build directory, and the pair
 * represents (filename, contents). So 
 *
 * ```
 * write_out_to_file "build" ("index.html", "<html></html>")
 * ```
 *
 * writes `<html></html>` to build/index.html
 *)
val write_out_to_file : string -> (string * string) -> unit

(**
 * Copy the contents of "static" from first path into the second path directory.
 * *)
val copy_static_dir : string -> string -> unit


(** Checks the existence of a filename *)
val check_exists : string -> bool
