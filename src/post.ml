open Printf
open Unix

open Core
open Re2.Std


type post_body = Split of (Omd.t * Omd.t) | Whole of Omd.t


type post = {
  title : string;
  datetime : Unix.tm;
  tags : string list;
  og_image : string option;
  og_description : string option;
  content : post_body;

  fs_path : string;
  reading_time : int;

  next_post_fs_path : (string * string) option;
  prev_post_fs_path : (string * string) option;
}

type t = post

let metadata_regex : Re2.regex = Re2.create_exn "^    ([^:]+): *(.+)$"
let filename_regex : Re2.regex = Re2.create_exn ".+/\\d\\d\\d\\d-\\d\\d-\\d\\d-([a-z-0-9]+)\\.md$"

let make_outfile_name input_filename datetime =
  let year = datetime.tm_year + 1900 in
  let month = datetime.tm_mon + 1 in
  let matches = Re2.find_submatches_exn filename_regex input_filename in
  let nm = matches.(1) |> Option.value_exn in
  Printf.sprintf "/%4d/%02d/%s.html" year month nm


let all_body = function
  | Split (top, bottom) -> List.append top bottom
  | Whole all -> all


let all_content {content; _} = all_body content

(** Doing the naive thing Medium stated they did way back when:
  *
  * > Read time is based on the average reading speed of an adult (roughly 275 WPM).
  * > We take the total word count of a post and translate it into minutes. Then, we
  * > add 12 seconds for each inline image. Boom, read time.
  *
  * May do the image count thing too, but for now, just naive split into words, ignore
  * inline Markdown or HTML.
  *)
let reading_time_for content =
  let rec words_in lst = 
    let num_words str =
      String.split_on_chars str ~on:['\t';'\n';' ']
      |> List.filter ~f:(fun x -> x <> "")
      |> List.length in
    let sum_all x = List.map ~f:words_in x |> List.fold_left ~f:(+) ~init:0 in
    match lst with
    | [] -> 0
    | x::xs -> let rst = match x with
      | Omd.H1 x -> words_in x
      | Omd.H2 x -> words_in x
      | Omd.H3 x -> words_in x
      | Omd.H4 x -> words_in x
      | Omd.H5 x -> words_in x
      | Omd.H6 x -> words_in x
      | Omd.Paragraph x -> words_in x
      | Omd.Text x -> num_words x
      | Omd.Emph x -> words_in x
      | Omd.Bold x -> words_in x
      | Omd.Ul x -> sum_all x
      | Omd.Ol x -> sum_all x
      | Omd.Ulp x -> sum_all x
      | Omd.Olp x -> sum_all x
      | Omd.Blockquote x -> words_in x
      | _ -> 0
    in rst + words_in xs
  in
  let corpus = all_body content in
  words_in corpus
  |> Pervasives.float_of_int
  |> (fun x -> x /. 275.0)
  |> Pervasives.ceil
  |> Pervasives.int_of_float


(** Given a bunch of non-metadata lines, returns it as either Whole or Split. We have to
 * do the Markdown parsing as whole since the links at the top might refer to links
 * at the bottom, so we pattern match the split later. *)
let handle_content contents = 
  let is_separator x = x <> Omd.Html_comment "<!-- more -->" in
  Utils.add_newlines contents
  |> Omd.of_string
  |> List.split_while ~f:is_separator
  |> function
    | (top, []) -> Whole top
    | (top, bottom) -> Split (top, List.drop bottom 3)
    (* We drop the first 3 here because they include the comment + newlines *)


(** At a high level, we go iterate through lines. First we take metadata
 * lines as long as possible. When they no longer match, we add to "prev"
 * until we optionally match the "<!-- more" signal, after which we
 * add to the end. *)
let split_contents lines =
  let rec split_meta remaining has_finished_meta meta rest =
    match remaining with
    | [] -> (List.rev meta, List.rev rest)
    | x::xs -> match (has_finished_meta, Re2.matches metadata_regex x) with
      | (false, true) -> split_meta xs false (x::meta) rest
      | (false, false) -> split_meta xs true meta rest
      | (true, _) -> split_meta xs has_finished_meta meta (x::rest) in
  let (meta, contents) = split_meta lines false [] [] in
  let parsed = handle_content contents in
  (meta, parsed)


(** Go through all your lines and eventually construct a tuple. This is designed inefficiently
 * but it's such a small amount of data anyways... *)
let handle_metadata data =

  let metadata_handle str = 
    let as_pair x = 
      let matches = Re2.find_submatches_exn metadata_regex x in
      (matches.(1) |> Option.value_exn, matches.(2) |> Option.value_exn)
    in
    List.map ~f:as_pair data
      |> List.filter ~f:(fun (x, _) -> String.equal x str)
      |> function
        | [(_, y)] -> Some (String.strip y)
        | _ -> None
  in

  let to_datetime = Fn.compose Unix.gmtime (ISO8601.Permissive.datetime ~reqtime:true) in

  let title = metadata_handle "Title" |> Option.value_exn in
  let datetime = metadata_handle "Date" |> Option.value_exn |> to_datetime in
  let tags = metadata_handle "Tags" |> Option.value_exn |> String.split ~on:',' |> List.map ~f:(String.strip ) in
  let og_img = metadata_handle "og_image" in
  let og_desc = metadata_handle "og_description" in
  (title, datetime, tags, og_img, og_desc)


let make_post contents =
  let (metadata, content) = Files.lines contents |> split_contents in
  let (title, datetime, tags, og_img, og_desc) = handle_metadata metadata in
  let pathname = make_outfile_name (Files.name contents) datetime in
  {
    title = title;
    datetime = datetime;
    tags = tags;
    og_image = og_img;
    og_description = og_desc;
    content = content;

    fs_path = pathname;
    reading_time = reading_time_for content;

    next_post_fs_path = None;
    prev_post_fs_path = None;
  }


(** Inverting the normal sort order since we want them in descending order *)
let compare_post_dates {datetime = datetime1;_} {datetime = datetime2;_} =
  let tm x = Unix.mktime x |> Utils.fst in
  match (tm datetime1) < (tm datetime2) with
  | true -> 1
  | _ -> -1


let title {title;_} = title
let datetime {datetime;_} = datetime
let tags {tags;_} = tags
let og_image {og_image;_} = og_image
let og_description {og_description;_} = og_description
let content {content;_} = content
let fs_path {fs_path;_} = fs_path
let reading_time {reading_time;_} = reading_time
let next_post_fs_path {next_post_fs_path;_} = next_post_fs_path
let prev_post_fs_path {prev_post_fs_path;_} = prev_post_fs_path


(* Pray, motherfuckers *)
let form_prev_next_links posts =
  let arr = Array.of_list posts in
  let fs_path_at x = 
    let p = (Array.get arr x) in
    Some (p.title, p.fs_path)
  in
  let foldable (count, accum) post =
    let (prev_in, next_in) = (count - 1, count + 1) in
    let (prev, next) =
      match (prev_in < 0, next_in >= List.length posts) with
      | (true, _) -> (None, fs_path_at next_in)
      | (_, true) -> (fs_path_at prev_in, None)
      | (_, _) -> (fs_path_at prev_in, fs_path_at next_in)
    in
    let updated_post =
      {post with next_post_fs_path = next; prev_post_fs_path = prev}
    in
    (count + 1, updated_post::accum)
  in
  List.fold_left ~f:foldable ~init:(0, []) posts
    |> Utils.snd
    |> List.rev


(** Do JSON libraries make this any easier? _Still_ no Deriving Show? O_O *)
let post_to_string {title; datetime; tags; og_image; og_description;
                    reading_time; next_post_fs_path;
                    prev_post_fs_path; _
                   } =
  let get_timestring x = Unix.mktime x |> (fun (x,_) -> x) |> ISO8601.Permissive.string_of_datetime in
  let time_str = get_timestring datetime in
  (* let content_str = match content with
    | Split (a,b) -> "Split(" ^ (Omd.to_html a) ^ " | " ^ (Omd.to_html b) ^ ")"
    | Whole x -> "Whole(" ^ (Omd.to_html x) ^ ")" in *)

  let tag_string = Utils.from_string_list tags in
  let og_img = Utils.option_maybe og_image in
  let og_desc = Utils.option_maybe og_description in
  let next_or_prev = function | None -> "None" | Some (p,_) -> p in
  let prev = next_or_prev prev_post_fs_path in
  let next = next_or_prev next_post_fs_path in

  Printf.sprintf "Post(title: %s; time: %s; tags: %s; og_image: %s; og_desc: %s; content: %s; reading_time: %d; next %s; prev %s)"
                  title time_str tag_string og_img og_desc (* content_str *) "CONTENT CONTENT" reading_time next prev
