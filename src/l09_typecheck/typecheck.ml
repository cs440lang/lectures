open Ast

type tenv = (string * typ) list

exception TypeError of string

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
          if t = t2 then t'
          else raise (TypeError "Function/Arg type mismatch")
      | _ -> raise (TypeError "Non-function type being applied"))

let typecheck e =
  let _ = typeof e [] in e
