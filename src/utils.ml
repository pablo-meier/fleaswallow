open Core
open Unix

open Re2.Std

(** Writable list from a string list *)
let from_string_list input =
  let folded = String.concat ~sep:"," input in
  "[" ^ folded ^ "]"


(** Writable String from string option *)
let option_maybe x = match x with
  | Some v -> v
  | None -> "None"


let fst (x,_) = x
let snd (_,y) = y


(** One big string from an array of them. *)
let add_newlines = String.concat ~sep:"\n"


(** Get all words contained in an element as a single string. *)
let words_in md_lst =
  let rec words_in_rec lst accum = match lst with
  | [] -> List.rev accum |> List.map ~f:String.strip |> String.concat ~sep:" "
  | x::xs -> match x with
    | Omd.Text x -> words_in_rec xs (x::accum)
    | Omd.Bold x -> words_in_rec xs ((words_in_rec x [])::accum)
    | Omd.Emph x -> words_in_rec xs ((words_in_rec x [])::accum)
    | Omd.Paragraph x -> words_in_rec xs ((words_in_rec x [])::accum)
    | Omd.Blockquote x -> words_in_rec xs ((words_in_rec x [])::accum)
    | Omd.Url (_, x, _) -> words_in_rec xs ((words_in_rec x [])::accum)
    | _ -> words_in_rec xs accum in
  words_in_rec md_lst []


(** Get up to 300 characters of words from the first non-header in a body of Markdown. *)
let rec get_desc lst = match lst with
  | [] -> ""
  | x::xs -> match x with
    | Omd.Paragraph x -> words_in x
    | _ -> get_desc xs


(** Prints a date-formatted as dashed pseudo-ISO8601 *)
let format_date_index {tm_mon; tm_mday; tm_year; _} =
  Printf.sprintf "%d-%02d-%02d" (tm_year + 1900) (tm_mon + 1) tm_mday


(** Prints the current time as an ISO date *)
let current_time_as_iso () =
  Unix.gettimeofday () |> ISO8601.Permissive.string_of_datetime


let to_dasherize = Re2.create_exn "[^a-zA-Z0-9]+"
let trailing_dash = Re2.create_exn "-$"
(** Sub out anything that isn't a number, letter, or dash. Lowercase all. Dashes where spaces lived. *)
let dasherized name =
  Re2.rewrite_exn to_dasherize ~template:"-" name
  |> Re2.rewrite_exn trailing_dash ~template:""
  |> String.lowercase
