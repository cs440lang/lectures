(* type synonyms *)

type point2d = float * float

let foo ((x,y) : point2d) = x *. y

type matrix = (int list) list 

let m : matrix = [[1;2;3];
                  [4;5;6];
                  [7;8;9]]

(* Algebraic Data Types - ADTs *)

(* simple enumeration-like type *)
type color = Red | Blue | Green 

let describe_color = function
  | Red -> "Warm"
  | Blue-> "Cool"
  | Green -> "Verdant"

(* constructors can carry additional data *)
type box = Box of int

let add_to_box i (Box j) = Box (i + j)

let add_to_box' i b = match b with
  | Box j -> Box (i + j) 

let add_to_box'' i = function
  | Box j -> Box (i + j) 

(* constructors can take different data *)
type shape = Circle of float
           | Rectangle of float * float
           | Triangle of float * float

let shape_area = function
  | Circle r -> Float.pi *. r *. r
  | Rectangle (l,w) -> l *. w
  | Triangle (b,h) -> b *. h /. 2.0

(* a recursive type *) 
type russian_doll = EmptyDoll
                  | Doll of russian_doll

let count_dolls d =
  let rec aux acc = function
    | EmptyDoll -> acc
    | Doll d' -> aux (acc + 1) d'
  in aux 0 d

(* a data structure *)
type int_list = INull
              | ICons of int * int_list

let l = ICons (1, ICons (2, ICons (3, INull)))

let rec sum_int_list = function
  | INull -> 0
  | ICons (x, l) -> x + sum_int_list l 

let rec int_list_from_range m n =
  if m = n then INull
  else ICons (m, int_list_from_range (m+1) n) 

(* Polymorphic types *) 

type 'a pbox = PBox of 'a

let unpack_pbox (PBox x) = x

(* option is defined by OCaml!  *)
type 'a option = None | Some of 'a

(* we use the option type to support well-typed "null" *)
let quadratic_roots a b c =
  let disc = (b *. b) -. (4. *. a *. c) in
  if disc < 0.0 then
    None
  else
    let sqrt_disc = sqrt disc in
    let r1 = (-.b +. sqrt_disc) /. (2. *. a) in
    let r2 = (-.b -. sqrt_disc) /. (2. *. a) in
    Some (r1, r2)

(* polymorphic type with multiple type vars *)
type ('a, 'b) either = Left of 'a | Right of 'b

let k2f t = if t < 0.
            then Left "Invalid temp"
            else Right (t -. 272.15)

(* our version of the built-in list *)
type 'a my_list = Null
                | Cons of 'a * 'a my_list

(* a binary tree *)
type ('k,'v) bin_tree = Nil
                      | Node of 'k * 'v
                                * ('k,'v) bin_tree
                                * ('k,'v) bin_tree

let rec tree_insert k v = function
  | Nil -> Node (k, v, Nil, Nil)
  | Node (k',v',l,r) ->
    if k < k'
    then Node (k',v',tree_insert k v l,r)
    else Node (k',v',l,tree_insert k v r )

let t = Nil
        |> tree_insert 10 "ten"
        |> tree_insert 5 "five"
        |> tree_insert 15 "fifteen"
        |> tree_insert 8 "eight"
        |> tree_insert 12 "twelve"

let rec inorder_list = function
  | Nil -> []
  | Node (k,v,l,r) -> inorder_list l @ [(k,v)] @ inorder_list r

