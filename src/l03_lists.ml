(* basic pattern matching *)

let first l = match l with
  | [] -> failwith "List is empty"
  | x :: _ -> x

let first' = function
  | [] -> failwith "List is empty"
  | x :: _ -> x

let rest = function
  | [] -> failwith "List is empty"
  | _ :: xs -> xs

(* processing lists *)

let rec sum = function
  | [] -> 0
  | x :: xs -> x + sum xs

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
  let rec fib = function
    | 0 -> 1
    | 1 -> 1
    | i -> fib (i-1) + fib (i-2)
  and gen j = if j=n
              then []
              else fib j :: gen (j+1)
  in gen 0

let fibs' n =
  let rec gen i j k acc =
    if k = n then reverse acc
    else gen j (i+j) (k+1) (i :: acc) 
  in gen 1 1 0 []

(* associative lists *)

let rec assoc k = function
  | [] -> raise Not_found
  | (k',v) :: xs when k = k' -> v
  | _ :: xs -> assoc k xs 
