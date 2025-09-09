let x = 5 + 2

(* let y = "hello" + 3   (* compile-time error *) *)

let square x = x * x

let inc x = x + 1

let apply_twice f x = f (f x)

type color =
  | Red
  | Green
  | Blue

type shape = Circle of color | Square of color;; 

let s : shape = Circle Blue

type point = float * float

let p : point = (2.0, -3.5)

let describe c =
  match c with
  | Red -> "warm"
  | Green -> "fuzzy"
  | Blue -> "cool"

let id x = x

let swap (x, y) = (y, x)

let make_big_list n =
  Array.init n (fun i -> i)
