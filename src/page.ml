open Core
open ISO8601.Permissive
open Re2.Std
open Re2.Infix
open Omd


type page = {
  title : string;
  description : string;
  fs_path : string;
  contents : Omd.t;
}

type t = page


let title {title; _} = title
let description {description; _} = description
let fs_path {fs_path; _} = fs_path
let contents {contents; _} = contents


let get_title_description content =
  let rec get_title lst = match lst with
    | [] -> ("NO GODS; NO TITLE", [])
    | x::xs -> match x with
      | Omd.H1 x -> (Utils.words_in x, xs)
      | Omd.H2 x -> (Utils.words_in x, xs)
      | Omd.H3 x -> (Utils.words_in x, xs)
      | Omd.H4 x -> (Utils.words_in x, xs)
      | Omd.H5 x -> (Utils.words_in x, xs)
      | Omd.H6 x -> (Utils.words_in x, xs)
      | _ -> get_title xs in
  let (title, rst) = get_title content in
  let description = Utils.get_desc rst in
  (title, description)


let to_page record =
  let contents =
    Files.lines record
    |> Utils.add_newlines
    |> Omd.of_string in
  let (title, description) = get_title_description contents in
  {
    title = title;
    description = description;
    fs_path = Files.name record;
    contents = contents;
  }
