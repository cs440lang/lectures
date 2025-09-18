let inc = fun x -> x + 1

(* syntactic sugar *) 

let inc' x = x + 1

let foo x y z = (2*x + y) * z

let foo' = fun x y z ->  (2*x + y) * z

(* multi-argument functions are "curried" *)

let foo'' = fun x ->
            fun y ->
            fun z -> (2*x + y) * z

let dist (x1,y1) (x2,y2) =
  sqrt ((x2-.x1)**2.+.(y2-.y1)**2.)

(* partial application *) 

let distFromOrigin = dist (0.0,0.0)

(* basic recursion *)

let rec fact n = if n <= 1 then 1
                 else n * fact (n-1)

let rec even n = if n = 0 then true
                 else odd (n-1)
    and odd n  = if n = 0 then false 
                 else even (n-1)

(* "Polymorphic" functions *)

let id x = x

let fst x _ = x
let snd _ y = y

(* a specialized identity function *) 

let id' x : int = x


(* using let expressions for local vars *)

let quadratic_roots a b c =
  let disc = (b *. b) -. (4. *. a *. c) in
  if disc < 0.0 then
    failwith "No real roots"
  else
    let sqrt_disc = sqrt disc in
    let r1 = (-.b +. sqrt_disc) /. (2. *. a) in
    let r2 = (-.b -. sqrt_disc) /. (2. *. a) in
    (r1, r2)


(* classic fibonacci generator *) 

let rec fib n = if n = 0 then 1
                else if n = 1 then 1
                else fib (n-1) + fib (n-2)

(* pattern matching *)

let rec fib' n = match n with
  | 0 -> 1
  | 1 -> 1
  | _ -> fib' (n-1) + fib' (n-2)

 let rec fib'' = function
  | 0 -> 1
  | 1 -> 1
  | n -> fib'' (n-1) + fib'' (n-2)


(* tail recursion *)

let rec sum n = if n = 0 then 0
                else n + sum (n-1)

let rec sum' n acc =
  if n = 0 then acc
  else sum' (n-1) (n+acc)

let sum'' n =
  let rec aux n acc =
    if n = 0 then acc
    else aux (n-1) (n+acc)
  in aux n 0


let fib''' n =
  let rec aux i j k =
    if k = 0 then i
    else aux j (i+j) (k-1)
  in aux 1 1 n

