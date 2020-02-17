open Core
open Command.Let_syntax

let toplevel new_post_title should_build should_debug () =
  let () = Logs.set_level @@ if should_debug then Some Logs.Debug else Some Logs.Info in
  let () = Logs.set_reporter (Logs.format_reporter ()) in
  match should_build with
  | true -> Fleaswallow_lib.build_site ()
  | false -> (
      match new_post_title with
      | Some x -> Fleaswallow_lib.create_new_post x
      | None -> Fleaswallow_lib.build_site () )


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
    [%map_open
      let title =
        flag
          "n"
          (optional string)
          ~doc:"  title - Generate a new file for a blog post with parameterized title."
      and should_build = flag "b" no_arg ~doc:"  build - Build the site"
      and should_debug = flag "d" no_arg ~doc:"  debug - Enable debug logs" in
      toplevel title should_build should_debug]


let () = Command.run ~version:"1.0" ~build_info:"P4BLO" command
