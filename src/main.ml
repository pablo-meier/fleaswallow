open Printf
open Core
open Unix


(** Some blog posts will have the same title but need different filenames (i.e.
 * if you have a weekly feature called "This Week" or somesuch, you'll need
 * this-week.md, this-week-2.md...
 *
 * While it hits the filesystem a _n_ times, I don't worry too much
 * for performance here.
 * *)
let conflict_free_filename directory basename =
  let rec iter suffix =
    let base_and_suffix = Printf.sprintf "%s-%d.md" basename suffix in
    let full_path = Filename.concat directory base_and_suffix in
    match Files.check_exists full_path with
    | true -> iter (suffix + 1)
    | false -> full_path
  in
  let full_path = (Filename.concat directory basename) ^ ".md" in
  match Files.check_exists full_path with
  | true -> iter 2
  | false -> full_path


let create_new_post name =
  let models = [
    ("title", Jg_types.Tstr name);
    ("datestring", Jg_types.Tstr (Utils.current_time_as_iso ()))
  ] in
  let body = Filename.concat "templates" "new-post.tmpl"
    |> Jg_template.from_file ~models:models
  in
  let posts_directory = "posts" in
  let basename = String.concat ~sep:"-" [
    (Unix.gettimeofday ()
     |> Unix.gmtime
     |> Utils.format_date_index);
    (Utils.dasherized name)]  in
  let filepath = conflict_free_filename posts_directory basename in
  let () = Files.write_out_to_file "./" (filepath, body) in
  Printf.printf "New post named \"%s\" at %s\n" name filepath


let build_site () =
  let () = Banner.print_banner () in
  let () = Logs.info (fun m -> m "Building site…") in
  let src_path = "./" in
  let model = Model.build_blog_model src_path in
  let build_dir = (Model.build_dir model) in
  let () =
    model
    |> Builder.build
    |> List.iter ~f:(Files.write_out_to_file build_dir) in
  Files.copy_static_dir src_path build_dir


let toplevel new_post_title should_build should_debug () =
  let () = Logs.set_level @@ if should_debug then (Some Logs.Debug) else (Some Logs.Info) in
  let () = Logs.set_reporter (Logs.format_reporter ()) in
  match should_build with
  | true -> build_site ()
  | false -> match new_post_title with
    | Some x -> create_new_post x
    | None -> build_site ()


let spec =
    let open Command.Spec in
    empty
    +> flag "-n" (optional string) ~doc:" title - Generate a new file for a blog post with parameterized title."
    +> flag "-b" no_arg ~doc:" Build the site."
    +> flag "-d" no_arg ~doc:" Enable debug logs."


let command =
    Command.basic
      ~summary:"Static site generator. Build your site like Pablo would."
      ~readme:(fun () ->
{|
Fleaswallow is a static site generator, optimized for blogs. If you run it in a
directory with the correct files, it will write HTML files you can push up to
S3 or GitHub Pages.

Below are the files it expects.

  * config.ini — An inifile with the toplevel metadata about your blog, and
    some configuration.

  * posts/ — a directory of Markdown files with a date convention
    `yyyy-mm-dd-title.md` These will map to URLs like `/yyyy/mm/title.html`

  * pages/ — a directory of Markdown files to serve as static pages. These
    are served at your document root, so `pages/About.md` is `/About.html`
    on your site.

  * templates/ — a list of .tmpl files for your pages and feeds. These are
    rendered as a subset of Django Templating Languages, per the library
    Fleaswallow uses (Jingoo).

  * static/ — whatever you'd like copied, as-is, into your document root
    This usually involves CSS, JavaScript, images, robots.txt, files…
|})
      spec
      toplevel

let () = Command.run ~version:"1.0" ~build_info:"RWO" command
