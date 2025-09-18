(* list processing *)

(* basic pattern matching *)

let first lst = match lst with
  | [] -> failwith "Empty list!"
  | x :: _ -> x

let rest lst = match lst with
  | [] -> failwith "Empty list!"
  | _ :: xs -> xs

(* list processing functions *)

let rec length = function
  | [] -> 0 
  | _ :: xs -> 1 + length xs

let rec index lst n =
  if n = 0 then first lst
  else index (rest lst) (n-1)

let index' lst n =
  let rec aux i = function
    | [] -> failwith "Empty list!"
    | x :: xs -> if i = n then x
                 else aux (i+1) xs
  in aux 0 lst

let rec append lst1 lst2 = match lst1 with
  | [] -> lst2
  | x :: xs -> x :: append xs lst2

let rec sum_list = function
  | [] -> 0
  | n :: ns -> n + sum_list ns

let sum_list' lst =
  let rec aux acc = function
    | [] -> acc
    | n :: ns -> aux (n + acc) ns 
  in aux 0 lst

let rec reverse = function
  | [] -> []
  | x :: xs -> append (reverse xs) [x]

let reverse' lst =
  let rec aux acc = function
    | [] -> acc
    | x :: xs -> aux (x :: acc) xs
  in aux [] lst 

(* list generating functions *)

let rec range m n = if m > n then []
                    else m :: range (m+1) n

let rec repeat n x = if n = 0 then []
                     else x :: repeat (n-1) x

let fibs n =
  let rec aux i j k acc =
    if k = n then reverse acc
    else aux j (i+j) (k+1) (i :: acc) 
  in aux 1 1 0 []
