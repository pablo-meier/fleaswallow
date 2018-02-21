(** "Imperative shell" functions for dealing with the filesystem. *)
open Core
open Filename
open Re2.Std
open Re2.Infix

type file_with_contents = {
  name : string;
  lines : string list;
}
type t = file_with_contents


let to_record x =
  {name = x; lines = In_channel.read_lines x}


let name {name;_} = name
let lines {lines;_} = lines


let whitelist = [".md$"; ".html$"]
let whitelist_regexes = List.map ~f:(Re2.create_exn ~options:[]) whitelist
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


let copy_static_dir toplevel build_dir =
  let static_dir = Filename.concat toplevel "static/" in
  FileUtil.cp ~force:Force ~recurse:true ~preserve:true [static_dir] build_dir;;
