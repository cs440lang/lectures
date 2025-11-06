open Ast

exception TypeError of string

type type_variable = int
type typ = TInt | TBool | TFun of typ * typ | TVar of type_variable
type type_env = (string * typ) list
type type_constraint = typ * typ
type substitution = (type_variable * typ) list

let rec string_of_type = function
  | TInt -> "int"
  | TBool -> "bool"
  | TVar n -> Printf.sprintf "'a%d" n
  | TFun (t1, t2) ->
      let lhs =
        match t1 with
        | TFun _ -> Printf.sprintf "(%s)" (string_of_type t1)
        | _ -> string_of_type t1
      in
      Printf.sprintf "%s -> %s" lhs (string_of_type t2)

let rec string_of_subst = function
  | [] -> ""
  | (n, typ) :: ss ->
      let s = Printf.sprintf "'a%d = %s\n" n (string_of_type typ) in
      s ^ string_of_subst ss

let string_of_constraint (lhs, rhs) =
  Printf.sprintf "%s ~ %s" (string_of_type lhs) (string_of_type rhs)

let fresh_int =
  let counter = ref 0 in
  fun () ->
    let v = !counter in
    incr counter;
    v

let fresh_var () = TVar (fresh_int ())

let lookup (tenv : type_env) (name : string) : typ =
  match List.assoc_opt name tenv with
  | Some typ -> typ
  | None -> raise (TypeError (Printf.sprintf "Unbound variable %s" name))

let rec collect_constraints_expr (tenv : type_env) (e : expr) :
    typ * type_constraint list =
  match e with
  | Int _ -> (TInt, [])
  | Bool _ -> (TBool, [])
  | Var x -> (lookup tenv x, [])
  | Binop (bop, e1, e2) -> (
      let t1, c1 = collect_constraints_expr tenv e1 in
      let t2, c2 = collect_constraints_expr tenv e2 in
      match bop with
      | Add | Mult ->
          let constraints = c1 @ c2 @ [ (t1, TInt); (t2, TInt) ] in
          (TInt, constraints)
      | Leq ->
          let constraints = c1 @ c2 @ [ (t1, TInt); (t2, TInt) ] in
          (TBool, constraints))
  | If (e1, e2, e3) ->
      let t = fresh_var () in
      let t1, c1 = collect_constraints_expr tenv e1 in
      let t2, c2 = collect_constraints_expr tenv e2 in
      let t3, c3 = collect_constraints_expr tenv e3 in
      let constraints =
        c1 @ c2 @ c3 @ [ (t1, TBool); (t, t2); (t, t3) ]
      in
      (t, constraints)
  | Let (x, e1, e2) ->
      let t1, c1 = collect_constraints_expr tenv e1 in
      let t2, c2 = collect_constraints_expr ((x, t1) :: tenv) e2 in
      (t2, c1 @ c2)
  | Fun (x, e) ->
      let tx = fresh_var () in
      let env = (x, tx) :: tenv in
      let te, constraints = collect_constraints_expr env e in
      (TFun (tx, te), constraints)
  | App (e1, e2) ->
      let t = fresh_var () in
      let t1, c1 = collect_constraints_expr tenv e1 in
      let t2, c2 = collect_constraints_expr tenv e2 in
      let constraints =
        c1 @ c2 @ [ (t1, TFun (t2, t)) ]
      in
      (t, constraints)

let empty_subst : substitution = []

let rec apply_subst_type (subst : substitution) (ty : typ) : typ =
  match ty with
  | TInt -> TInt
  | TBool -> TBool
  | TFun (t1, t2) ->
      let t1' = apply_subst_type subst t1 in
      let t2' = apply_subst_type subst t2 in
      TFun (t1', t2')
  | TVar v -> (
      match List.assoc_opt v subst with
      | None -> TVar v
      | Some ty' -> apply_subst_type subst ty')

let compose_subst (s2 : substitution) (s1 : substitution) : substitution =
  let s1' = List.map (fun (v, ty) -> (v, apply_subst_type s2 ty)) s1 in
  s2 @ s1'

let rec occurs (v : type_variable) = function
  | TInt | TBool -> false
  | TVar v' -> v = v'
  | TFun (t1, t2) -> occurs v t1 || occurs v t2

let bind_variable (v : type_variable) (ty : typ) : substitution =
  match ty with
  | TVar v' when v = v' -> empty_subst
  | _ ->
      if occurs v ty then
        raise
          (TypeError
             (Printf.sprintf "Cannot construct infinite type %s ~ %s"
                (string_of_type (TVar v)) (string_of_type ty)))
      else [ (v, ty) ]

let rec unify (t1 : typ) (t2 : typ) : substitution =
  match (t1, t2) with
  | TInt, TInt -> empty_subst
  | TBool, TBool -> empty_subst
  | TFun (a1, b1), TFun (a2, b2) ->
      let s1 = unify a1 a2 in
      let b1' = apply_subst_type s1 b1 in
      let b2' = apply_subst_type s1 b2 in
      let s2 = unify b1' b2' in
      compose_subst s2 s1
  | TVar v, ty | ty, TVar v -> bind_variable v ty
  | _ ->
      raise
        (TypeError
           (Printf.sprintf "Type mismatch: %s vs %s" (string_of_type t1)
              (string_of_type t2)))

let solve_constraints (constraints : type_constraint list) : substitution =
  List.fold_left
    (fun subst (lhs, rhs) ->
      let lhs' = apply_subst_type subst lhs in
      let rhs' = apply_subst_type subst rhs in
      let new_subst = unify lhs' rhs' in
      compose_subst new_subst subst)
    empty_subst constraints

let rec repl () =
  print_string "> ";
  flush stdout;
  match read_line () with
  | "" -> ()
  | line -> (
      try
        let e = Eval.parse line in
        let raw_type, constraints = collect_constraints_expr [] e in
        if constraints <> [] then (
          Printf.printf "Raw type: %s\n"
            (string_of_type raw_type);
          print_endline "Constraints:";
          List.iteri
            (fun idx constraint_eq ->
              Printf.printf "C%d: %s\n" (idx + 1)
                (string_of_constraint constraint_eq))
            constraints );
        let subst = solve_constraints constraints in
        let typ = apply_subst_type subst raw_type in
        print_string (string_of_subst subst);
        Printf.printf "- : %s\n" (string_of_type typ);
        repl ()
      with TypeError msg ->
        print_endline msg;
        repl ())
