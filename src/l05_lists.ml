(* basic pattern matching *)

let is_empty lst =
  match lst with
  | [] -> true
  | _ -> false

let head = function
  | [] -> failwith "empty list"
  | x :: _ -> x

let tail = function
  | [] -> failwith "empty list"
  | _ :: xs -> xs

let is_singleton = function
  | [x] -> true
  | _ -> false

let sum_next_two = function
  | _ :: x :: y :: _ -> x + y
  | _ -> 0

let first_of_first = function
  | (x :: _) :: _ -> x
  | _ -> failwith "bad structure"

(* processing lists *)

let rec length = function
  | [] -> 0
  | _ :: xs -> 1 + length xs

let rec sum = function
  | [] -> 0
  | x :: xs -> x + sum xs

(* building lists *)

let rec range n =
  if n <= 0 then []
  else n :: range (n - 1)

(* processing & building lists *)

let rec double = function
  | [] -> []
  | x :: xs -> (2 * x) :: double xs

let rec map f = function
  | [] -> []
  | x :: xs -> f x :: map f xs

let rec filter p = function
  | [] -> []
  | x :: xs when p x -> x :: filter p xs
  | _ :: xs -> filter p xs

(* concatenating lists *)

let rec append lst1 lst2 =
  match lst1 with
  | [] -> lst2
  | x :: xs -> x :: append xs lst2

(* inefficient reverse - O(N^2) *)

let rec reverse = function
  | [] -> []
  | x :: xs -> reverse xs @ [x]

(* accumulator-driven, tail-recursive reverse - O(N) *)

let rec reverse' lst acc =
  match lst with
  | [] -> acc
  | x :: xs -> reverse' xs (x :: acc)

(* tail-recursive version with helper *)

let reverse'' lst =
  let rec aux acc = function
    | [] -> acc
    | x :: xs -> aux (x :: acc) xs in
  aux [] lst

(* tail-recursive map *)

let map' f lst =
  let rec aux acc = function
    | [] -> List.rev acc (* reverse the accumulated result *)
    | x :: xs -> aux (f x :: acc) xs in
  aux [] lst

(* associative lists *)

let rec assoc k = function
  | [] -> raise Not_found
  | (k',v) :: xs when k = k' -> v
  | _ :: xs -> assoc k xs 

let mem_assoc k alst = 
  try
    let _ = assoc k alst in true
  with
  | Not_found -> false
