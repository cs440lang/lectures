(* Lambda Calculus interpreter *) 

type term = Var of string
          | Abs of string * term
          | App of term * term

(* identity *)
let id = Abs ("x", (Var "x"))
let id2 = App (id, id)

(* Booleans *)
let t_true  = Abs ("x", (Abs ("y", (Var "x"))))
let t_false = Abs ("x", (Abs ("y", (Var "y"))))
let t_if = Abs ("b", Abs ("t", Abs ("f",
             App (App (Var "b", Var "t"), Var "f"))))

let t_ifeg = App (App (App (t_if, t_true), id), id2)

(* Church numerals *)
let c0 = Abs ("f", (Abs ("x", (Var "x"))))
let c1 = Abs ("f", (Abs ("x", App (Var "f", Var "x"))))
let c2 = Abs ("f", (Abs ("x", App (Var "f", App (Var "f", Var "x")))))

let inc = Abs ("n", Abs ("f", Abs ("x",
            App (Var "f", App (App (Var "n", Var "f"), Var "x")))))

let c3 = App (inc, c2)
let c4 = App (inc, c3)

(* some combinators *)
let omega = let w = Abs ("x", (App ((Var "x"), (Var "x")))) in App (w,w)
let y = let x = Abs ("x", App (Var "f", App (Var "x", Var "x")))
        in Abs ("f", App (x, x))

(* potential variable capture *)
let t_capture = App (Abs ("x", Abs ("y", Var "x")),
                     Var "y")

(* normal vs. applicative order biased *)
let t_lazy  = App (Abs ("x", Var "y"), c3)
let t_eager = App (Abs ("x", App (Var "x", Var "x")), id2)
       
(* pretty printer *)
let pp t =
  let rec aux ctx = function
    | Var x -> x
    | Abs (x, t) ->
        let body = aux 0 t in
        let s = Printf.sprintf "λ%s.%s" x body in
        if ctx > 0 then "(" ^ s ^ ")" else s
    | App (t1, t2) ->
        let s = Printf.sprintf "%s %s" (aux 1 t1) (aux 2 t2) in
        if ctx = 2 then "(" ^ s ^ ")" else s
  in aux 0 t

(* subst x v t = [v/x]t *)
let rec subst v x t = failwith "unimplemented"
  
(* normal-order (leftmost-outermost) step function
 * - if a redex exists in t, perform it and return Some t'
 * - else return None *)
let rec step_normal t = failwith "unimplemented"

(* normal-order multi-step eval *)
let rec eval_normal t = failwith "unimplemented"
