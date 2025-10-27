(* tuples *)

let pt : float * float = (2.17, 3.14)


(* records *)

type student = { name : string; id : int; gpa : float; }

let michael : student = { name="Michael"; id=1234567; gpa=3.5 }


(* type synonyms *)

type point2d = float * float

let foo ((x,y) : point2d) = x *. y

type int_matrix = (int list) list 

let m : int_matrix = [[1;2;3];
                      [4;5;6];
                      [7;8;9]]

type 'a matrix = ('a list) list

let m' : float matrix = [[1.;2.;3.];
                         [4.;5.;6.];
                         [7.;8.;9.]]

(* Algebraic Data Types - ADTs *)

(* simple enumeration-like type *)
type color = Red | Blue | Green 


(* constructors can carry additional data *)
type box = Box of int


(* constructors can take different data *)
type shape = Circle of float
           | Rectangle of float * float
           | Triangle of float * float


(* a recursive type *) 
type russian_doll = EmptyDoll
                  | Doll of russian_doll


(* a data structure *)
type int_list = Null
              | Cons of int * int_list


(* Polymorphic types *) 

type 'a pbox = PBox of 'a


(* option is defined by OCaml!  *)
type 'a option = None | Some of 'a


(* we use the option type to support well-typed "null" *)
let quadratic_roots a b c =
  let disc = (b *. b) -. (4. *. a *. c) in
  if disc < 0.0 then failwith "No real roots"
  else
    let sqrt_disc = sqrt disc in
    let r1 = (-.b +. sqrt_disc) /. (2. *. a) in
    let r2 = (-.b -. sqrt_disc) /. (2. *. a) in
    (r1, r2)

let rec assoc k = function
  | [] -> raise Not_found
  | (k',v) :: xs when k = k' -> v
  | _ :: xs -> assoc k xs 

(* polymorphic type with multiple type vars *)
type ('a, 'b) either = Left of 'a | Right of 'b

(* use either to return an error string or temp *)
let k2f t = if t < 0. then invalid_arg "Invalid temperature"
            else t -. 272.15

(* our version of the built-in list *)
type 'a my_list = Null'
                | Cons' of 'a * 'a my_list

(* a binary tree *)
type ('k,'v) bin_tree = Nil
                      | Node of 'k * 'v
                                * ('k,'v) bin_tree
                                * ('k,'v) bin_tree

let rec tree_insert k v = failwith "Unimplemented"

(*
let t = Nil
        |> tree_insert 10 "ten"
        |> tree_insert 5 "five"
        |> tree_insert 15 "fifteen"
        |> tree_insert 8 "eight"
        |> tree_insert 12 "twelve"
*)

let rec inorder_list t = failwith "Unimplemented"
