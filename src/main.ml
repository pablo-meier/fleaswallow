open Printf
open Core
open Unix


let create_new_post name =
  let title = name in
  let datestring = Utils.current_time_as_iso () in
  let empty_body =
{|   Title: |} ^ title ^ {|
   Date: |} ^ datestring ^ {|
   Tags: DRAFT
   og_image:
   og_description: 

_The song for this post is [][], by ._

Be brilliant!

<!-- more -->
|} in
  let filepath =
    (Unix.gettimeofday ()
     |> Unix.gmtime
     |> Utils.format_date_index) ^ "-" ^ (Utils.dasherized name) ^ ".md" in
  let () = Files.write_out_to_file "posts/" (filepath, empty_body) in
  Printf.printf "New post named \"%s\" at %s\n" name ("posts/" ^ filepath)


let build_site () =
  let src_path = "./" in
  let model = Model.build_blog_model src_path in
  let build_dir = (Model.build_dir model) in
  let () =
    model
    |> Builder.build
    |> List.iter ~f:(Files.write_out_to_file build_dir) in
  Files.copy_static_dir src_path build_dir



let toplevel new_post_title should_build () =
  match should_build with
  | true -> build_site ()
  | false -> match new_post_title with
    | Some x -> create_new_post x
    | None -> build_site ()


let spec =
    let open Command.Spec in
    empty
    +> flag "-n" (optional string) ~doc:"title - Generate a new file for a blog post with parameterized title."
    +> flag "-b" no_arg ~doc:" Build the site."


let command =
    Command.basic
      ~summary:"Static site generator. Build your site like Pablo would."
      ~readme:(fun () ->
{|
Fleaswallow is a static site generator, optimized for blogs. If you run it in a
directory with the correct files, it will write HTML files you can push up to
S3 or GitHub Pages.

Below are the files it expects. To see a sample site layout, run with
"-new-site <name>" to have sample in `<name>`

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
