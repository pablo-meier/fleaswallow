open Core

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
