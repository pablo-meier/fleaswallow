open Printf
open Core


let create_new_post name =
  Printf.printf "New post named %s\n" name


let build_site () =
  let src_path = "./" in
  let model = Model.build_blog_model src_path in
  let build_dir = (Model.build_dir model) in
  let () =
    model
    |> Builder.build
    |> List.iter ~f:(Files.write_out_to_file build_dir) in
  Files.copy_static_dir src_path build_dir



let toplevel new_post should_build () =
    match should_build with
    | true -> build_site ()
    | false -> match new_post with
      | Some postname -> create_new_post postname
      | None -> Printf.printf "Whaaaaat?"


let spec =
    let open Command.Spec in
    empty
    +> flag "-n" (optional string) ~doc:"Generate a new file for a blog post with parameterized title."
    +> flag "-b" no_arg ~doc:" Build the site."


let command =
    Command.basic
      ~summary:"Static site generation with goodies"
      ~readme:(fun () ->
{|
I'd like to learn a bit more OCaml and do a few more things than Frog will let
me at present, so we have Battletoads!
|})
      spec
      toplevel

let () = Command.run ~version:"1.0" ~build_info:"RWO" command
