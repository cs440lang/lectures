open Ast

type tenv = (string * typ) list
(** Type environment mapping variable names to their types, most recent binding
    first. *)

exception TypeError of string
(** Raised when static checking encounters an ill-typed expression. *)

(** [string_of_type t] pretty-prints a [typ] using ML-style arrows. Nested
    function domains are parenthesized on the left so that
    [TFun (TFun (TInt, TBool), TInt)] renders as "(int -> bool) -> int". *)
let rec string_of_type : typ -> string = function
  | TInt -> "int"
  | TBool -> "bool"
  | TFun (t1, t2) ->
      let lhs =
        match t1 with
        | TFun _ -> Printf.sprintf "(%s)" (string_of_type t1)
        | _ -> string_of_type t1
      in
      Printf.sprintf "%s -> %s" lhs (string_of_type t2)

(** [typeof e tenv] computes the static type of expression [e] under type
    environment [tenv], raising [TypeError] if [e] is ill-typed. Examples:
    - [typeof (Int 42) [] = TInt]
    - [typeof (Fun ("x", TInt, Var "x")) [] = TFun (TInt, TInt)]
    - [typeof (App (Fun ("x", TInt, Bool true), Int 0)) []] raises [TypeError].
*)
let rec typeof (e : expr) (tenv : tenv) =
  match e with
  | Int _ -> TInt
  | Bool _ -> TBool
  | Var x -> (
      match List.assoc_opt x tenv with
      | Some t -> t
      | None -> raise (TypeError (Printf.sprintf "%s undeclared" x)))
  | Binop (bop, e1, e2) -> (
      let t1 = typeof e1 tenv in
      let t2 = typeof e2 tenv in
      match (bop, t1, t2) with
      | Add, TInt, TInt -> TInt
      | Mult, TInt, TInt -> TInt
      | Leq, TInt, TInt -> TBool
      | _ -> raise (TypeError "Invalid bop operands"))
  | If (e1, e2, e3) ->
      let t1 = typeof e1 tenv in
      if t1 <> TBool then raise (TypeError "Invalid guard")
      else
        let t2 = typeof e2 tenv in
        let t3 = typeof e3 tenv in
        if t2 = t3 then t3 else raise (TypeError "Branches don't match")
  | Let (x, e1, e2) ->
      let t = typeof e1 tenv in
      typeof e2 ((x, t) :: tenv)
  | Fun (x, t, e) ->
      let t' = typeof e ((x, t) :: tenv) in
      TFun (t, t')
  | App (e1, e2) -> (
      let t1 = typeof e1 tenv in
      let t2 = typeof e2 tenv in
      match t1 with
      | TFun (t, t') ->
          if t = t2 then t' else raise (TypeError "Function/Arg type mismatch")
      | _ -> raise (TypeError "Non-function type being applied"))

(** [typecheck e] validates [e] in the empty environment, propagating
    [TypeError] on failure and returning [e] unchanged on success. *)
let typecheck e =
  let _ = typeof e [] in
  e
