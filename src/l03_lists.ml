  
(* list processing *)

let first (x :: _) = x

let first' lst =
  match lst with
  | (x :: _) -> x
  | _ -> failwith "List is empty!"

let rest (x :: xs) = xs

let second (_ :: x :: _) = x

let third (_ :: _ :: x :: _) = x


let rec length = function
  | [] -> 0
  | _ :: xs -> 1 + length xs

let rec sum = function
  | [] -> 0
  | x :: xs -> x + sum xs

let index n lst =
  let rec aux i = function
    | [] -> failwith "Index out of bounds"
    | x :: xs -> if i = 0 then x else aux (i-1) xs
  in aux n lst

let rec append l1 l2 =
  match l1 with
  | [] -> l2
  | x :: rest -> x :: append rest l2

(* list generation *)

