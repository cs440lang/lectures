let apply f x = f x

let compose f g = fun x -> f (g x) 

(* map a function over a list, producing a new list *)
let rec map f = failwith "Unimplemented"

(* filter values from a list based on a predicate  *)
let rec filter p = failwith "Unimplemented"

(* the "right fold" distills the primitive
   recursive pattern over lists *)
let rec fold_right f z = function
  | [] -> z
  | x :: xs -> f x (fold_right f z xs)

(* applications of the right fold *)
let sum lst = fold_right (+) 0 lst

let product lst = fold_right ( * ) 1 lst

let filter' p lst = failwith "Unimplemented"

let append l1 l2 = failwith "Unimplemented"

(* the "left fold" distills the tail-recursive,
 * accumulator-based recursive pattern over lists  *)
let rec fold_left f acc = function
  | [] -> acc
  | x :: xs -> fold_left f (f acc x) xs

(* applications of the left fold *)
let sum' lst = fold_left (+) 0 lst 

let product' lst = fold_left ( * ) 1 lst 

let reverse lst = failwith "Unimplemented"

let count_freq lst = failwith "Unimplemented"

(* binary tree from before *)
type ('k,'v) bin_tree = Nil
                      | Node of 'k * 'v
                                * ('k,'v) bin_tree
                                * ('k,'v) bin_tree

let t = Node (10, "ten",
              Node(5, "five",
                   Node (1, "one", Nil, Nil),
                   Node (7, "seven", Nil, Nil)),
              Node(15, "fifteen",
                   Node (12, "twelve", Nil, Nil),
                   Node (18, "eighteen", Nil, Nil)))

(* map for trees *)
let rec tree_map f = failwith "Unimplemented"

(* fold for trees *)
let rec tree_fold f y = failwith "Unimplemented"

(* closures *)
let adder x = let n = x in
              fun y -> n + y

let make_counter init = let c = ref init in
                        fun () -> c := !c + 1 ; !c

