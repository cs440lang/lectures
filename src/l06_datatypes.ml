open List

(* variants *)

type color = Red | Green | Blue

let describe_color: color -> string = function
  | Red -> "Warm"
  | Green -> "Verdant"
  | Blue -> "Cool"

(* tuples *)

let dist (x1,y1) (x2,y2) = sqrt ((x1-.x2)**2. +. (y1-.y2)**2.)

let swap (x,y) = (y,x)

(* unit and the side-effect pattern *)

let inc_and_print x =
  let () = print_string "x = " in
  let () = print_int x in
  let () = print_newline () in
  x + 1

let inc_and_print' x =
  let () = Format.printf "x = %d\n" x in
  x + 1

let inc_and_print'' x =
  print_string "x = ";
  print_int x;
  print_newline ();
  x + 1

(* records *)

type student = { name: string; id: int; gpa: float; }

let michael : student = { name="Michael"; id=1234567; gpa=3.5 }

let jane = { michael with name="Jane"; id=2345678 }

(* type Synonyms *)

type point = float * float

type piece = char
type loc = int * int
type 'a matrix = ('a list) list

let tic_tac_toe_play p (r,c) board =
  let row = nth board r in
  take r board @
  [take c row @ [p] @ drop (c+1) row]  
  @ drop (r+1) board

(* Algebraic Data Types - ADTs *)

(* enumerating values *)

type t1 = Foo | Bar 
type t2 = Lah | Dee | Dah
type t3 = { f1: t1; f2: t2; f3: t1 }
type t4 = Unit | Box of t1 | Trunk of bool * t3

(* shape ADT *)

type shape = Circle of float
           | Rectangle of float * float
           | Triangle of float * float

let shape_area: shape -> float = function
  | Circle r -> Float.pi *. r *. r
  | Rectangle (l,w) -> l *. w
  | Triangle (b,h) -> b *. h /. 2.0

(* cards ADT *)

type suit = Diamonds | Clubs | Hearts | Spades
type rank = Num of int | Jack | Queen | King | Ace
type card = rank * suit

let card_value : card -> int = function
  | (Ace, _)   -> 11
  | (King, _) | (Queen, _) | (Jack, _) -> 10
  | (Num n, _) -> n

let is_blackjack (c1, c2) =
  card_value c1 + card_value c2 = 21

(* polymorphic types *) 

(* option type *)

type 'a option = None | Some of 'a

let quadratic_roots a b c =
  let disc = (b *. b) -. (4. *. a *. c) in
  if disc < 0.0 then None
  else
    let sqrt_disc = sqrt disc in
    let r1 = (-.b +. sqrt_disc) /. (2. *. a) in
    let r2 = (-.b -. sqrt_disc) /. (2. *. a) in
    Some (r1, r2)

let rec assoc_opt k = function
  | [] -> None
  | (k',v) :: xs when k = k' -> Some v
  | _ :: xs -> assoc_opt k xs 

(* result type *)

type ('a, 'b) result = Ok of 'a | Error of 'b

let quadratic_roots' a b c =
  if a = 0.0 then Error "not quadratic (a=0)"
  else
    let disc = (b *. b) -. (4. *. a *. c) in
    if disc < 0.0 then Error "no real roots"
    else
      let sqrt_disc = sqrt disc in
      let r1 = (-.b+.sqrt_disc) /. (2.*.a) in
      let r2 = (-.b-.sqrt_disc) /. (2.*.a) in
      Ok (r1, r2)

(* our version of the built-in list *)

type 'a my_list = Null
                | Cons of 'a * 'a my_list

let rec sum = function
  | Null -> 0
  | Cons (x,xs) -> x + sum xs

let rec range n =
  if n <= 0 then Null
  else Cons (n, range (n-1))
  
(* a binary tree *)

type ('k,'v) bin_tree = Nil
                      | Node of 'k * 'v
                                * ('k,'v) bin_tree
                                * ('k,'v) bin_tree

(* binary-search insert *)
let rec tree_insert k v = function
  | Nil -> Node (k, v, Nil, Nil)
  | Node (k',v',l,r) ->
    (* insert smaller keys into the left subtree *)
    if k < k' then Node (k',v',tree_insert k v l,r)
    (* and larger keys into the right subtree *)
    else Node (k',v',l,tree_insert k v r )

let t = Nil
        |> tree_insert 10 "ten"
        |> tree_insert 5 "five"
        |> tree_insert 15 "fifteen"
        |> tree_insert 8 "eight"
        |> tree_insert 12 "twelve"

(* in-order binary-search tree traversal *)
let rec inorder_list = function
  | Nil -> []
  | Node (k,v,l,r) -> inorder_list l @ [(k,v)] @ inorder_list r

(* mutually-recursive types *)

type element = { tag : string; children : node list }
 and node = Text of string | Element of element

let doc = Element {
    tag = "div"; children = [
      Text "Hello, ";
      Element { tag = "b"; children = [Text "world"] };
      Text "!"
    ]}

let rec text_of_node = function
  | Text s -> s
  | Element e -> text_of_element e
and text_of_element { tag; children } =
  children |> List.map text_of_node |> String.concat "" 

(* exceptions *)

exception Eek
exception Uhoh of string
exception CodedError of int * string

let boombastic = function
  | n when n < 0 -> raise Eek
  | 0 -> "zero"
  | n when n < 1000 -> raise (CodedError (n, "Blue") )
  | _ -> failwith "Fell through!"

(* exception handling *)

let defuse n =
  try
    boombastic n
  with
  | Eek -> "negative"
  | CodedError (n,msg) -> Format.sprintf "%s %d" msg n
  | Failure msg -> msg
  | _ -> "catchall"

(* modules *)

module Adder : sig
  val add : int -> int -> int
end = struct
  let inc x = x + 1
  let dec x = x - 1
  let rec add x y = match (x,y) with
    | (0,n) | (n,0) -> n
    | (m,n) -> add (dec m) (inc n)
end

(* a simple module type *)

module type Adder = sig
  val add : int -> int -> int
end

module SimpleAdder : Adder = struct
  let add x y = x + y
end

module RecursiveAdder : Adder = struct
  let inc x = x + 1
  let dec x = x - 1
  let rec add x y = match (x,y) with
    | (0,n) | (n,0) -> n
    | (m,n) -> add (dec m) (inc n)
end

(* an abstract Map type *)

module type Map = sig
  type ('k, 'v) t
  exception Not_found
  val empty : ('k, 'v) t
  val insert : 'k -> 'v -> ('k, 'v) t -> ('k, 'v) t
  val lookup : 'k -> ('k, 'v) t -> 'v
end

(* assoc-list map implementation *)

module AssocListMap : Map = struct
  exception Not_found
  type ('k, 'v) t = ('k * 'v) list
  let empty = []
  let insert k v m = (k, v) :: m
  let rec lookup k = function
    | [] -> raise Not_found
    | (k',v) :: xs when k = k' -> v
    | _ :: xs -> lookup k xs
end

(* bin-search-tree map implementation *)

module TreeMap : Map = struct
  exception Not_found
  type ('k,'v) t =
    | Nil
    | Node of 'k * 'v * ('k,'v) t * ('k,'v) t

  let empty = Nil

  let rec insert k v = function
    | Nil -> Node (k, v, Nil, Nil)
    | Node (k',v',l,r) ->
      if k < k' then Node (k',v',insert k v l,r)
      else Node (k',v',l,insert k v r )

  let rec lookup k = function
    | Nil -> raise Not_found
    | Node (k',v,_,_) when k = k' -> v
    | Node (k',v,l,r) ->
      if k < k' then lookup k l
      else lookup k r 
end
