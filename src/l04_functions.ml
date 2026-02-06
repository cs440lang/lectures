(* Basic Functions ***********************************************************)

let inc = fun x -> x + 1

let inc' x = x + 1

let foo = fun x y -> 2*x + y

let foo' = fun x -> fun y -> 2*x + y

let r = let loc_fn x = x*x in
        loc_fn 10

let dist x1 y1 x2 y2 = sqrt ((x2-.x1)**2.+.(y2-.y1)**2.)

let distFromOrigin = dist 0.0 0.0

(* Polymorphic functions *****************************************************)

let id x = x

let first x _ = x
let second _ y = y

(* a specialized identity function *) 
let id' x : int = x

(* Operators *****************************************************************)

let (+++) x y = x + 3*y

let (|>) x f = f x

let (@@) f x = f x

(* Pattern Matching **********************************************************)

let isOrigin p =
  if fst p = 0 && snd p = 0 then true else false

let isOrigin' p =
  match p with
  | (0, 0) -> true
  | _ -> false

let isOrigin'' = function
  | (0, 0) -> true
  | _ -> false

let addPoints p1 p2 =
  match (p1, p2) with
  | ((x1, y1), (x2, y2)) -> (x1 + x2, y1 + y2)

let addPoints' (x1, y1) (x2, y2) = (x1 + x2, y1 + y2)

let swap (x, y) = (y, x)

let fst3 (x, _, _) = x
let snd3 (_, y, _) = y  
let thd3 (_, _, z) = z

let isWeekend = function
  | "Saturday" | "Sunday" -> true
  | _ -> false

let isDigit = function
  | '0'..'9' -> true
  | _ -> false

let describeNumber = function
  | n when n < 0 -> "negative"
  | 0 -> "zero"
  | n when n < 10 -> "small positive"
  | n when n < 100 -> "medium positive"
  | _ -> "large positive"

(* Recursion *****************************************************************)

let rec fact n = if n <= 1 then 1
                 else n * fact (n-1)

(* mutual recursion *)
let rec even n = if n = 0 then true
                 else odd (n-1)
    and odd n  = if n = 0 then false 
                 else even (n-1)

let rec sum n = if n = 0 then 0
                else n + sum (n-1)

let rec fib = function
  | 0 -> 1
  | 1 -> 1
  | n -> fib (n-1) + fib (n-2)

(* Tail Recursion ************************************************************)

let rec sum' n acc = if n = 0 then acc
                     else sum' (n-1) (n+acc)

let sum'' n =
  let rec aux n acc = if n = 0 then acc
                      else aux (n-1) (n+acc) in
  aux n 0


let fib' n =
  let rec aux i j = function
    | 0 -> i
    | k -> aux j (i+j) (k-1) in
  aux 1 1 n
