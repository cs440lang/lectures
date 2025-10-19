let apply f x = f x

let compose f g = fun x -> f (g x) 

(* map a function over a list, producing a new list *)
let rec map f = function
  | [] -> []
  | x :: xs -> f x :: map f xs

(* filter values from a list based on a predicate  *)
let rec filter p = function
  | [] -> []
  | x :: xs when p x -> x :: filter p xs
  | _ :: xs -> filter p xs

(* the "right fold" distills the primitive recursive pattern over lists *)
let rec fold_right f z = function
  | [] -> z
  | x :: xs -> f x (fold_right f z xs)

(* applications of the right fold *)
let sum lst = fold_right (+) 0 lst

let product lst = fold_right ( * ) 1 lst

let filter' p lst = fold_right (fun x r -> if p x then x :: r
                                           else r)
                               []
                               lst

let append l1 l2 = fold_right (fun x r -> x :: r)
                              l2
                              l1

(* the "left fold" distills the tail-recursive, accumulator-based
 * recursive pattern over lists  *)
let rec fold_left f acc = function
  | [] -> acc
  | x :: xs -> fold_left f (f acc x) xs

(* applications of the left fold *)
let sum' lst = fold_left (+) 0 lst (* tail-recursive! *)

let product' lst = fold_left ( * ) 1 lst (* tail-recursive! *)

let reverse lst = fold_left (fun acc x -> x::acc) [] lst

let count_freq lst =
  let rec inc_key k = function
    | [] -> [(k, 1)]
    | (k', n) :: es when k' = k -> (k, n+1) :: es
    | e :: es -> e :: inc_key k es 
  in
  fold_left (fun acc x -> inc_key x acc) [] lst

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
let rec tree_map f = function
  | Nil -> Nil
  | Node (k,v,l,r) ->
    let k',v' = f (k,v) in
    Node (k', v', tree_map f l, tree_map f r)

(* fold for trees *)
let rec tree_fold f y = function
  | Nil -> y
  | Node (k,v,l,r) -> f (k,v) (tree_fold f y l) (tree_fold f y r)

(* inorder traversal in terms of fold *)
let inorder_list t = tree_fold (fun x l r -> l @ [x] @ r) [] t

(* closures *)
let adder x = let n = x in
              fun y -> n + y

let make_counter init = let c = ref init in
                        fun () -> c := !c + 1 ; !c

