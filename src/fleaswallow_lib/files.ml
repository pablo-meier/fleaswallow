open Core
(** "Imperative shell" functions for dealing with the filesystem. *)

open Filename
open Re2

type file_with_contents = {
  name: string;
  lines: string list;
  last_modified: int;
}

type t = file_with_contents

let to_record filename =
  let stat_record = Unix.stat filename in
  {
    name = filename;
    lines = In_channel.read_lines filename;
    last_modified = int_of_float stat_record.st_mtime;
  }


let name { name; _ } = name

let lines { lines; _ } = lines

let contents { lines; _ } = Utils.add_newlines lines

let last_modified { last_modified; _ } = last_modified

let file_contents path =
  try Some (to_record path) with
  | Sys_error _ -> None


let check_exists path =
  match Sys.file_exists ~follow_symlinks:true path with
  | `No -> false
  | `Yes
  | `Unknown ->
      true


let whitelist = [".md$"; ".html$"]

let whitelist_regexes = List.map ~f:(Re2.create_exn ~options:Options.default) whitelist

let in_whitelist x = List.exists whitelist_regexes ~f:(fun y -> Re2.matches y x)

(** Retrieves files from a directory and their contents as lines *)
let file_contents_in_dir dirname =
  Sys.readdir dirname
  |> Array.to_list
  |> List.map ~f:(Filename.concat dirname)
  |> List.filter ~f:in_whitelist
  |> List.map ~f:to_record


let write_out_to_file build_dir (path, content) =
  let filename = Filename.concat build_dir path in
  let () = Unix.mkdir_p (dirname filename) in
  Out_channel.write_all filename ~data:content


let copy_static_dir_if_necessary toplevel build_dir timestamp =
  let static_dir = Filename.concat toplevel "static/" in
  let last_modified = (Unix.stat static_dir).st_mtime in
  let observed_last_modified = int_of_float last_modified in
  let cached_last_modified = int_of_float (Unix.timegm timestamp) in
  let () =
    match observed_last_modified > cached_last_modified with
    | true ->
        Logs.info (fun m -> m "Copying static directory…");
        FileUtil.cp ~force:Force ~recurse:true ~preserve:true [static_dir] build_dir
    | false ->
        Logs.info (fun m -> m "Determined no fresh content in static directory, not copying…");
        ()
  in
  Unix.gmtime last_modified
