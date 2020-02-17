open Core

(** Some blog posts will have the same title but need different filenames (i.e. * if you have a
    weekly feature called "This Week" or somesuch, you'll need * this-week.md, this-week-2.md... * *
    While it hits the filesystem a _n_ times, I don't worry too much * for performance here. * *)
let conflict_free_filename directory basename =
  let rec iter suffix =
    let base_and_suffix = Printf.sprintf "%s-%d.md" basename suffix in
    let full_path = Filename.concat directory base_and_suffix in
    match Files.check_exists full_path with
    | true -> iter (suffix + 1)
    | false -> full_path
  in
  let full_path = Filename.concat directory basename ^ ".md" in
  match Files.check_exists full_path with
  | true -> iter 2
  | false -> full_path


let create_new_post name =
  let models =
    ["title", Jg_types.Tstr name; "datestring", Jg_types.Tstr (Utils.current_time_as_iso ())]
  in
  let body = Filename.concat "templates" "new-post.tmpl" |> Jg_template.from_file ~models in
  let posts_directory = "posts" in
  let basename =
    String.concat
      ~sep:"-"
      [Unix.gettimeofday () |> Unix.gmtime |> Utils.format_date_index; Utils.dasherized name]
  in
  let filepath = conflict_free_filename posts_directory basename in
  let () = Files.write_out_to_file "./" (filepath, body) in
  Printf.printf "New post named \"%s\" at %s\n" name filepath


let build_site () =
  let () = Banner.print_banner () in
  let () = Logs.info (fun m -> m "Building site…") in
  let src_path = "./" in
  let cache = src_path |> Cache.get_cache in
  let model = src_path |> Cache.model_updates cache in
  let build_dir = model |> Model.build_dir in
  let () = model |> Builder.build |> List.iter ~f:(Files.write_out_to_file build_dir) in
  let last_static_copy_time = cache |> Cache.last_copy_static in
  let copy_time = Files.copy_static_dir_if_necessary src_path build_dir last_static_copy_time in
  Cache.update_cache model copy_time
