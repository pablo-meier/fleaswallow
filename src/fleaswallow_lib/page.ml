open Core

type page = {
  title: string;
  description: string;
  input_fs_path: string;
  output_fs_path: string;
  contents: string;
}

type t = page

let title { title; _ } = title

let description { description; _ } = description

let output_fs_path { output_fs_path; _ } = output_fs_path

let input_fs_path { input_fs_path; _ } = input_fs_path

let contents { contents; _ } = contents

let strip_markdown_header x = x

let make_outfile_name input_filename =
  let base_name, _ = input_filename |> Filename.basename |> Filename.split_extension in
  base_name ^ ".html"


let get_title_description content =
  let get_title lst =
    match lst with
    | [] -> "NO GODS; NO TITLE", []
    | x :: xs -> x |> strip_markdown_header, xs
  in
  let title, rst = get_title content in
  let description = Utils.get_desc rst in
  title, description


let to_page record =
  let contents = record |> Files.lines in
  let title, description = get_title_description contents in
  let as_markdown = contents |> Utils.add_newlines |> Utils.cmark_from_string in
  {
    title;
    description;
    input_fs_path = Files.name record;
    output_fs_path = record |> Files.name |> make_outfile_name;
    contents = as_markdown;
  }
