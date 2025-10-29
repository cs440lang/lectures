open Ast

exception TypeError of string

(* Type representation                                                       *)

type type_variable = int
type typ = TInt | TBool | TFun of typ * typ | TVar of type_variable
type type_scheme = Forall of type_variable list * typ
type type_env = (string * type_scheme) list
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

let apply_subst_scheme (subst : substitution) (Forall (vars, ty)) =
  let filtered_subst =
    List.filter (fun (v, _) -> not (List.mem v vars)) subst
  in
  Forall (vars, apply_subst_type filtered_subst ty)

let apply_subst_env (subst : substitution) (env : type_env) : type_env =
  List.map (fun (name, scheme) -> (name, apply_subst_scheme subst scheme)) env

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

let free_type_vars_scheme (Forall (vars, ty)) =
  let ty_vars = free_type_vars_type ty in
  List.fold_left (fun acc v -> IntSet.remove v acc) ty_vars vars

let free_type_vars_env (env : type_env) =
  List.fold_left
    (fun acc (_, scheme) -> IntSet.union acc (free_type_vars_scheme scheme))
    IntSet.empty env

(* Generalisation and instantiation                                          *)

let generalize (env : type_env) (ty : typ) : type_scheme =
  let env_vars = free_type_vars_env env in
  let ty_vars = free_type_vars_type ty in
  let generalized = IntSet.elements (IntSet.diff ty_vars env_vars) in
  Forall (generalized, ty)

let instantiate (Forall (vars, ty) : type_scheme) : typ =
  let subst = List.map (fun v -> (v, fresh_type ())) vars in
  apply_subst_type subst ty

(* Unification                                                               *)

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

(* Type inference (Algorithm W)                                              *)

let lookup (env : type_env) (name : string) : type_scheme =
  match List.assoc_opt name env with
  | Some scheme -> scheme
  | None -> raise (TypeError (Printf.sprintf "Unbound variable %s" name))

let rec infer_expr (env : type_env) (e : expr) : substitution * typ =
  match e with
  | Int _ -> (empty_subst, TInt)
  | Bool _ -> (empty_subst, TBool)
  | Var name ->
      let scheme = lookup env name in
      (empty_subst, instantiate scheme)
  | Let (name, value_expr, body_expr) ->
      let s1, value_type = infer_expr env value_expr in
      let env1 = apply_subst_env s1 env in
      let scheme = generalize env1 value_type in
      let env2 = (name, scheme) :: env1 in
      let s2, body_type = infer_expr env2 body_expr in
      let subst = compose_subst s2 s1 in
      (subst, apply_subst_type subst body_type)
  | Fun (param, body) ->
      let param_type = fresh_type () in
      let env' = (param, Forall ([], param_type)) :: env in
      let s_body, body_type = infer_expr env' body in
      let param_type' = apply_subst_type s_body param_type in
      let subst = s_body in
      let fn_type = TFun (param_type', body_type) in
      (subst, apply_subst_type subst fn_type)
  | App (fn, arg) ->
      let s_fn, fn_type = infer_expr env fn in
      let env1 = apply_subst_env s_fn env in
      let s_arg, arg_type = infer_expr env1 arg in
      let result_type = fresh_type () in
      let s_unify =
        unify (apply_subst_type s_arg fn_type) (TFun (arg_type, result_type))
      in
      let subst = compose_subst s_unify (compose_subst s_arg s_fn) in
      (subst, apply_subst_type subst result_type)
  | _ -> failwith "Unimplemented"

let infer (expr : expr) : typ =
  let subst, ty = infer_expr [] expr in
  apply_subst_type subst ty
