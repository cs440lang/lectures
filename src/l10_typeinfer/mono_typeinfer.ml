open Ast

exception TypeError of string

type type_variable = int
type typ = TInt | TBool | TFun of typ * typ | TVar of type_variable
type type_env = (string * typ) list
type substitution = (type_variable * typ) list

(* Fresh type variables                                                      *)

let fresh_type_variable =
  let counter = ref 0 in
  fun () ->
    let v = !counter in
    incr counter;
    v

let fresh_type () = TVar (fresh_type_variable ())

(* Pretty-printing                                                           *)

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

(* Substitutions                                                             *)

let empty_subst : substitution = []

let rec string_of_subst = function
  | [] -> ""
  | (n, typ) :: ss ->
      let s = Printf.sprintf "'a%d = %s\n" n (string_of_type typ) in
      s ^ string_of_subst ss

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

let apply_subst_env (subst : substitution) (env : type_env) : type_env =
  List.map (fun (name, typ) -> (name, apply_subst_type subst typ)) env

let compose_subst (s2 : substitution) (s1 : substitution) : substitution =
  let s1' = List.map (fun (v, ty) -> (v, apply_subst_type s2 ty)) s1 in
  s2 @ s1'

(* Free type variables                                                       *)

module IntSet = Set.Make (Int)

let rec free_type_vars_type = function
  | TInt | TBool -> IntSet.empty
  | TVar v -> IntSet.singleton v
  | TFun (t1, t2) ->
      IntSet.union (free_type_vars_type t1) (free_type_vars_type t2)

let lookup (tenv : type_env) (name : string) : typ =
  match List.assoc_opt name tenv with
  | Some typ -> typ
  | None -> raise (TypeError (Printf.sprintf "Unbound variable %s" name))

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

let rec infer_expr (tenv : type_env) (e : expr) : substitution * typ =
  match e with
  | Int _ -> (empty_subst, TInt)
  | Bool _ -> (empty_subst, TBool)
  | Var name -> (empty_subst, lookup tenv name)
  | Binop (bop, e1, e2) ->
      let s1, t1 = infer_expr tenv e1 in
      let env1 = apply_subst_env s1 tenv in
      let s2, t2 = infer_expr env1 e2 in
      let operand_type = apply_subst_type s2 t1 in
      let combined = compose_subst s2 s1 in
      begin match bop with
      | Add | Mult ->
          let s3 = unify operand_type TInt in
          let s4 = unify (apply_subst_type s3 t2) TInt in
          let subst = compose_subst s4 (compose_subst s3 combined) in
          (subst, apply_subst_type subst TInt)
      | Leq ->
          let s3 = unify operand_type TInt in
          let s4 = unify (apply_subst_type s3 t2) TInt in
          let subst = compose_subst s4 (compose_subst s3 combined) in
          (subst, apply_subst_type subst TBool)
      end
  | If (guard, then_branch, else_branch) ->
      let s1, t_guard = infer_expr tenv guard in
      let env1 = apply_subst_env s1 tenv in
      let s_bool = unify t_guard TBool in
      let env2 = apply_subst_env s_bool env1 in
      let s_then, t_then = infer_expr env2 then_branch in
      let env3 = apply_subst_env s_then env2 in
      let s_else, t_else = infer_expr env3 else_branch in
      let s_branch = unify (apply_subst_type s_else t_then) t_else in
      let subst =
        compose_subst s_branch
          (compose_subst s_else
             (compose_subst s_then (compose_subst s_bool s1)))
      in
      (subst, apply_subst_type subst t_else)
  | Let (name, value_expr, body_expr) ->
      let s1, value_type = infer_expr tenv value_expr in
      let env1 = apply_subst_env s1 tenv in
      let s2, body_type = infer_expr ((name, value_type) :: env1) body_expr in
      let subst = compose_subst s2 s1 in
      (subst, apply_subst_type subst body_type)
  | Fun (param, body) ->
      let param_type = fresh_type () in
      let env = (param, param_type) :: tenv in
      let s_body, body_type = infer_expr env body in
      let param_type' = apply_subst_type s_body param_type in
      let subst = s_body in
      let fn_type = TFun (param_type', body_type) in
      (subst, apply_subst_type subst fn_type)
  | App (fn, arg) ->
      let s_fn, fn_type = infer_expr tenv fn in
      let env1 = apply_subst_env s_fn tenv in
      let s_arg, arg_type = infer_expr env1 arg in
      let result_type = fresh_type () in
      let s_unify =
        unify (apply_subst_type s_arg fn_type) (TFun (arg_type, result_type))
      in
      let subst = compose_subst s_unify (compose_subst s_arg s_fn) in
      (subst, apply_subst_type subst result_type)

let rec repl () =
  print_string "> ";
  flush stdout;
  match read_line () with
  | "" -> ()
  | line -> (
      try
        let e = Eval.parse line in
        let subst, typ = infer_expr [] e in
        print_string (string_of_subst subst);
        Printf.printf "- : %s\n" (string_of_type typ);
        repl ()
      with TypeError msg ->
        print_endline msg;
        repl ())
