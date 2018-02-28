open Printf
open Core
open Unix


let print_banner () =
  let () = Printf.printf {| ,gggggggggggggg
dP""""""88"""""" ,dPYb,                                                             ,dPYb, ,dPYb,
Yb,_    88       IP'`Yb                                                             IP'`Yb IP'`Yb
 `""    88       I8  8I                                                             I8  8I I8  8I
     ggg88gggg   I8  8'                                                             I8  8' I8  8'
        88   8   I8 dP   ,ggg,     ,gggg,gg    ,g,     gg    gg    gg     ,gggg,gg  I8 dP  I8 dP    ,ggggg,    gg    gg    gg
        88       I8dP   i8" "8i   dP"  "Y8I   ,8'8,    I8    I8    88bg  dP"  "Y8I  I8dP   I8dP    dP"  "Y8ggg I8    I8    88bg
  gg,   88       I8P    I8, ,8I  i8'    ,8I  ,8'  Yb   I8    I8    8I   i8'    ,8I  I8P    I8P    i8'    ,8I   I8    I8    8I
   "Yb,,8P      ,d8b,_  `YbadP' ,d8,   ,d8b,,8'_   8) ,d8,  ,d8,  ,8I  ,d8,   ,d8b,,d8b,_ ,d8b,_ ,d8,   ,d8'  ,d8,  ,d8,  ,8I
     "Y8P'      8P'"Y88888P"Y888P"Y8888P"`Y8P' "YY8P8PP""Y88P""Y88P"   P"Y8888P"`Y88P'"Y888P'"Y88P"Y8888P"    P""Y88P""Y88P"

                                                  NKkddolloxxxkOKWW
                                               WKkdlccccccccccccldk0XW
                                             WKxlcclllllllllllllllccco0W
                                           WXxlcllllllllllllllllllllc:ckN
                                          NOocllllllllllllllllllllllllc:xX
                                        NOoclllllllllllllllllllllllllllc:oK
 W0dlcc:cccclodxkO00KXNWMMMMMMMMMMMMWWN0occlllllllllllllllllllllllllllllc:l0W
 Nd'............'',,;cldxOO0KXXXKKK0KK0xddxxdoooollllllllllllllllllllllllc:cOW
 Wx'....................',,;clllccclodddxxO00OO00OkkOkxdddooddoolllllllllllccON
  Kl..........................'',;:::::::ccclloodddxkOOkO0OOO00OkkkxkkkxxxddxxOKXNW
  W0c..............................',;:cclccccccc:::cccclllooodddddxkOOkkOkO00OOkk0NW
   W0c..................................',:cllllllllllcccccccc:::::ccccccccllllooollxkkO0KXNNWWW
    WKl'.....................'',,,,,,,''....';:ccllllllllllllllllllllllllccccccccccccc::ccllooooddddxxxxxkkkkkkkkO000KXN
     WNk:.................',;:clllllllc:;,'....'',:ccllllllllllllllllllllllllllllllllllllllllllccccc::::::::::::;::;,',;
       WKd,..............;:loxkkOkkkkxxxdoc:,'......',;:cclllllllllllllllllllllllllllllllllllllllllllllllllllcc:;,''..'c
         W0l,...........;ldkO000000000000Oxol;'..........',;;::cclllllllllllllllllllllllllllllllllllllcc::;,''.......:kN
           N0o;'.......:odkOO00000000OOOOOOkxo:''''............'',,;::ccccllllllllllllllllcccc::;;;,,''............;xX
             WKxl;''..,oxxO0OO0kolc:;;d0KXXKkxl;,,''''''..............'',,,,,,,,,,,,,,,,,'''....................'cxKW
                NKkdl;:oxkKNXXXO; cKNNNKkxo:;;;;,,,'''''''''''''';;:::::::::;;;;;;;;;;,..................':d0N
                    Nx:lxk0XNNNXx;...:OXNNX0kxl:;;;;;;;;;;,,,,,,,,,;clodxddolccccclllllcccc;..............,cx0N
                    Wk;cdxkKXNNNNX0OKXNNNNKkxdc;;;;;;;;;;;;;;;;;;;;cdxkKXXXKo......cxkkkkxdo;.........,cokKN
                   WXo,;ldxk0KXNNNNNNNNNX0kxdc;;;;;;;;;;;;;;;;;;;;;cdxOXNNNK: cKXNNXOxd:'.',:codOKNW
                 N0xc;;::codxkO0KKKKKK0Okxdl:;;;;;;;;;;;;;;;;;;;;;;cdxOKNNNXk,. .:OXNNNKOxo:,oKXNW
               WKxlcllcc::::loddxxkkkxddoc:;;;;;;;;;:::;;;;;;;;;;;;:oxxOXNNNXKkddOXXNNNKOxdl;:O
              Xkdddxddddoolc::::cccccc::;;;;;;;;;;:looll::;:::::;;;;:oxxO0XXNNNNNNNNNX0kxdl:;:O
             Xkdxxxxxxxdxxxddollc:;;;;;;;;;;;;;;;:odc,:docclolllc:;;;:lodxkO0KKXKKK00Oxdoc::;,lKW
             Xxdxxxxxxdc;codxxxxdoolcc::;;;;;;;:codd;.;ddddl:,,ooc;;;;;:cloddxxkkxxxdolc:;;::;;ckN
             Nkodxxxxxdo:,'';clddxxxxddoollllloodxxdocoxxxxl;,;odo::;;;;;;::ccccccccccccccllooollxKW
              Xkoddxxxxxxdoc;''',:coddxxxxxxxxxxxxxxxxxxxxxddodxxxdolcccccccccccllloooddddxxxxxxdddKW
               Nkccodddxxxxxxdoc;,''',;:clodxxxxxxxxxxxxxxxxxxxxxxxxxddddddddddxxxxxxxxddoolclddxxdkN
                Xl'';cloddxxxxxxxxdoc:;,'''',;:clloddddxxxxxxxxxxxxxxxxxxxxxdddoolcc:;,,'',,;coxxxdON
                 Kc..'',;clodddxxxxxxxxddolc:;,,,''''',,,;;;::::::::::;;;;,,,,,''',,,;;:cloddxxxddxKW
                  Kc.'''.',,;::cloodddxdxxxxxxxddoollc:::;;;;;;,,,,,,,;;;::ccllooodddxxxxxxxddddxOXW
                   Xl''..'''''''',,;:cclooddddxxxxxxxxxxxxxxxxxxxxxddxxxxxxxxxxxxxxxxddddoollokKNW
                    Nx;'co;'''..'''.''',,,,;::ccllooooddddddddddddddddddddddddoooollcc:;;,,,c0W
                     WK0NWKxc;co:'..'',,''..'''''',,,,;;;:::::::::::::::::;;;;;,,,''''...,:dX
                            WXNWKolxo,'';ol,','''''',,,,,,,,,,,'',,',,,,,,,,'',,,''..',,l0NW
                                 WWMN0xx0WNO:',d0o,.'''''',,,,,'',,,,,,,,,,''',,';l::xKXN
                                           WKdkNMNx'.......''';:,'''''','''';;,:xKWNNW
                                                 Wk,.'','''coxKN0olk0x::oolxXXKXW
|} in
  Printf.printf "\n%!"


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
  let title = name in
  let datestring = Utils.current_time_as_iso () in
  let empty_body =
{|    Title: |} ^ title ^ {|
    Date: |} ^ datestring ^ {|
    Tags: DRAFT
    og_image:
    og_description:

<small><em>The song for this post is <a href=""></a>, by .</em></small>

Be brilliant!

<!-- more -->

|} in
  let posts_directory = "posts" in
  let basename = String.concat ~sep:"-" [
    (Unix.gettimeofday ()
     |> Unix.gmtime
     |> Utils.format_date_index);
    (Utils.dasherized name)]  in
  let filepath = conflict_free_filename posts_directory basename in
  let () = Files.write_out_to_file "./" (filepath, empty_body) in
  Printf.printf "New post named \"%s\" at %s\n" name filepath


let build_site () =
  let () = print_banner () in
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
