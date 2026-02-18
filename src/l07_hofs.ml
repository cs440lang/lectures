let apply f x = f x

let flip f = fun x y -> f y x

let compose f g = fun x -> f (g x) 

let even = compose ((==) 0) (flip (mod) 2)

(* the "right fold" distills the pattern of primitive recursion *)
let rec fold_right f lst z = match lst with
  | [] -> z
  | x :: xs -> f x (fold_right f xs z)

(* applications of the right fold *)
let sum lst = fold_right (+) lst 0

let concat lst = fold_right (^) lst ""

let map f lst = fold_right (fun x res -> f x :: res) lst []

(* the "left fold" distills the tail-recursive accumulation pattern *)
let rec fold_left f acc = function
  | [] -> acc
  | x :: xs -> fold_left f (f acc x) xs

(* applications of the left fold *)
let sum' lst = fold_left (+) 0 lst

let length lst = fold_left (fun acc _ -> acc + 1) 0 lst

let reverse lst = fold_left (fun acc x -> x::acc) [] lst

let map' f lst = fold_left (fun acc x -> f x :: acc) [] lst
               |> List.rev

(* closures *)
let dist_between (x1,y1) (x2,y2) =
  sqrt ((x2-.x1)**2. +. (y2-.y1)**2.0)

let dist_from_origin = dist_between (0.,0.)

let adder = let n = 42 in
            fun x -> x + n

let make_adder n = fun x -> x + n

let add5  = make_adder 5
let add10 = make_adder 10

let make_counter () =
  let count = ref 0 in
  fun () -> count := !count + 1 ; !count

