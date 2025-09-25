(* basic pattern matching *)

let first = function
  | x :: _ -> x
  | [] -> failwith "List is empty"

let rest = function
  | _ :: xs -> xs
  | _ -> failwith "List is empty"

(* processing lists *)

let rec index lst n =
  if n = 0 then first lst
  else index (rest lst) (n-1)

let rec length = function
  | [] -> 0
  | _ :: xs -> 1 + length xs

(* tail recursive version *)
let length' lst =
  let rec aux acc = function 
    | [] -> acc
    | _ :: xs -> aux (1 + acc) xs
  in aux 0 lst

let rec index n = function
  | [] -> failwith "Index out of range"
  | x :: xs -> if n = 0 then x
               else index (n-1) xs

let rec append lst1 lst2 = match lst1 with
  | [] -> lst2
  | x :: xs -> x :: append xs lst2
 
(* poor runtime complexity -- O(n^2) *)
let rec reverse = function
  | [] -> []
  | x :: xs -> append (reverse xs) [x]

(* much more efficient with an accumulator *)
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
