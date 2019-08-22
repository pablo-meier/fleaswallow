type page = {
  title : string;
  description : string;
  fs_path : string;
  contents : string;
}

type t = page

let title { title; _ } = title

let description { description; _ } = description

let fs_path { fs_path; _ } = fs_path

let contents { contents; _ } = contents

let strip_markdown_header x = x

let get_title_description content =
  let get_title lst =
    match lst with
    | [] -> ("NO GODS; NO TITLE", [])
    | x :: xs -> (x |> strip_markdown_header, xs)
  in
  let title, rst = get_title content in
  let description = Utils.get_desc rst in
  (title, description)

let to_page record =
  let contents = record |> Files.lines in
  let title, description = get_title_description contents in
  let as_markdown =
    contents |> Utils.add_newlines |> Utils.cmark_from_string
  in
  { title; description; fs_path = Files.name record; contents = as_markdown }
