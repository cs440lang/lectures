open Ast

(* This module implements Algorithm W for Hindley-Milner style type inference
   over the lambda calculus language defined in [Ast].  The comments explain
   both the concepts and how each helper participates in the algorithm, and
   give miniature examples that can be simulated by hand. *)

exception TypeError of string

(* Type representation                                                       *)

type type_variable = int
type typ = TInt | TBool | TFun of typ * typ | TVar of type_variable
type type_scheme = Forall of type_variable list * typ
type type_env = (string * type_scheme) list
type substitution = (type_variable * typ) list

(* Fresh type variables                                                      *)

(* [fresh_int ()] returns an integer identifier that is unique for
   every call during a single run.  This acts as the "name supply" in Algorithm
   W.  Example: calling it three times produces the sequence 0, 1, 2, which are
   later rendered as the schematic type variables `'a0`, `'a1`, ... *)
let fresh_int =
  let counter = ref 0 in
  fun () ->
    let v = !counter in
    incr counter;
    v

(* [fresh_type ()] wraps a new identifier as an unification variable.  We use
   fresh types when inferring the type of a function parameter or an unknown
   application result.  Example: [fresh_type ()] might yield [TVar 3], which
   stands in for the yet-unknown type `'a3`. *)
let fresh_type () = TVar (fresh_int ())

(* Pretty-printing                                                           *)

(* [collect_type_vars ty acc] gathers type variables in [ty] following their
   order of appearance so that we can assign prettified names deterministically. *)
let rec collect_type_vars ty acc =
  match ty with
  | TInt | TBool -> acc
  | TVar v ->
      if List.mem v acc then acc else acc @ [ v ]
  | TFun (t1, t2) ->
      let acc' = collect_type_vars t1 acc in
      collect_type_vars t2 acc'

(* [name_of_index i] maps 0 -> ['a], 1 -> ['b], ..., 26 -> ['a1], etc. *)
let name_of_index idx =
  let base = Char.code 'a' in
  let letter = Char.chr (base + (idx mod 26)) in
  if idx < 26 then Printf.sprintf "'%c" letter
  else Printf.sprintf "'%c%d" letter (idx / 26)

(* [string_of_type ty] produces an OCaml-style string using the naming scheme
   ['a], ['b], ..., ['a1], ['b1], ... based on first appearance in [ty].
   Example: [string_of_type (TFun (TVar 2, TFun (TVar 0, TVar 2)))]
   prints ["'a -> 'b -> 'a"]. *)
let string_of_type ty =
  let vars = collect_type_vars ty [] in
  let mapping = List.mapi (fun idx v -> (v, name_of_index idx)) vars in
  let rec to_string = function
    | TInt -> "int"
    | TBool -> "bool"
    | TVar v -> (
        match List.assoc_opt v mapping with
        | Some name -> name
        | None -> "'_" )
    | TFun (t1, t2) ->
        let lhs =
          match t1 with
          | TFun _ -> Printf.sprintf "(%s)" (to_string t1)
          | _ -> to_string t1
        in
        Printf.sprintf "%s -> %s" lhs (to_string t2)
  in
  to_string ty

(* Substitutions                                                             *)

let empty_subst : substitution = []

(* [apply_subst_type subst ty] walks over [ty] and replaces the free variables
   using the associations in [subst].  Any variable not present in the
   substitution is left untouched.  Example: with
   [subst = [ (0, TInt); (1, TBool) ]], applying to
   [TFun (TVar 0, TVar 2)] produces [TFun (TInt, TVar 2)].  Note how `'a2
   remains because it does not appear in [subst]. *)
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

(* [apply_subst_scheme subst (Forall (vars, ty))] first drops any mapping for
   the generalized variables [vars] (because they are bound) and then applies
   the remaining substitution to the body [ty].  Example: if a scheme is
   [Forall ([0], TVar 0)] and [subst = [ (0, TInt); (1, TBool) ]], the result
   is still [Forall ([0], TVar 0)] because `'a0 is protected, while `'a1 would
   still be substituted if it appeared. *)
let apply_subst_scheme (subst : substitution) (Forall (vars, ty)) =
  let filtered_subst =
    List.filter (fun (v, _) -> not (List.mem v vars)) subst
  in
  Forall (vars, apply_subst_type filtered_subst ty)

(* [apply_subst_env subst env] rewrites every scheme in the environment with
   [apply_subst_scheme].  This keeps the environment consistent after we learn
   new equalities.  Example: if [env] binds [x] to
   [Forall ([], TVar 0)] and [subst] forces [TVar 0] to [TInt], then
   [apply_subst_env subst env] binds [x] to [Forall ([], TInt)]. *)
let apply_subst_env (subst : substitution) (env : type_env) : type_env =
  List.map (fun (name, scheme) -> (name, apply_subst_scheme subst scheme)) env

(* [compose_subst s2 s1] applies [s2] after [s1].  Operationally, we first
   push [s2] through the range of [s1] and then append the mappings of [s2].
   This makes composition associative in the same direction that Algorithm W
   generates substitutions.  Example: composing
   [s1 = [ (0, TVar 1) ]] with [s2 = [ (1, TInt) ]] yields
   [ [ (1, TInt); (0, TInt) ] ], which when applied behaves as expected:
   `'a0` ultimately becomes `int`. *)
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

(* [free_type_vars_scheme (Forall (vars, ty))] returns the free type variables
   of [ty] after removing the universally quantified variables [vars].
   Example: for [Forall ([0], TFun (TVar 0, TVar 1))] the result is the set
   {1}, because `'a0 is locally bound but `'a1 escapes. *)
let free_type_vars_scheme (Forall (vars, ty)) =
  let ty_vars = free_type_vars_type ty in
  List.fold_left (fun acc v -> IntSet.remove v acc) ty_vars vars

(* [free_type_vars_env env] computes the union of free variables from every
   scheme in the environment.  This is used during generalization to avoid
   quantifying over variables that are still mentioned in the environment.
   Example: if [env] = [ ("x", Forall ([], TVar 0));
   ("y", Forall ([1], TFun (TVar 1, TVar 2))) ] then the result set is {0, 2}. *)
let free_type_vars_env (env : type_env) =
  List.fold_left
    (fun acc (_, scheme) -> IntSet.union acc (free_type_vars_scheme scheme))
    IntSet.empty env

(* Generalisation and instantiation                                          *)

(* [generalize env ty] abstracts the type variables in [ty] that are not
   already fixed by the environment, producing a polymorphic [type_scheme].
   Example: with [env] containing only [("id", Forall ([], TFun (TVar 0, TVar 0)))]
   and [ty = TFun (TVar 1, TVar 1)], the result is
   [Forall ([1], TFun (TVar 1, TVar 1))], which corresponds to the usual
   polymorphic identity type. *)
let generalize (env : type_env) (ty : typ) : type_scheme =
  let env_vars = free_type_vars_env env in
  let ty_vars = free_type_vars_type ty in
  let generalized = IntSet.elements (IntSet.diff ty_vars env_vars) in
  Forall (generalized, ty)

(* [instantiate scheme] replaces each quantified variable with a fresh type
   variable so that we can use the scheme at a concrete call site.  Example:
   instantiating [Forall ([0], TFun (TVar 0, TVar 0))] twice yields two
   unrelated types [TFun (TVar 3, TVar 3)] and [TFun (TVar 5, TVar 5)], allowing
   the same [id] function to be used at different types. *)
let instantiate (Forall (vars, ty) : type_scheme) : typ =
  let subst = List.map (fun v -> (v, fresh_type ())) vars in
  apply_subst_type subst ty

(* Unification                                                               *)

(* [occurs v ty] checks whether the type variable [v] appears inside [ty].
   This is the "occurs check" that prevents us from constructing infinite
   types, such as trying to solve `'a = 'a -> 'b`. *)
let rec occurs (v : type_variable) = function
  | TInt | TBool -> false
  | TVar v' -> v = v'
  | TFun (t1, t2) -> occurs v t1 || occurs v t2

(* [bind_variable v ty] links the variable [v] with [ty] in the current
   substitution.  If [ty] already equates [v] with itself we return the empty
   substitution; otherwise we ensure the occurs check passes.  Example:
   binding [v = 0] with [ty = TInt] yields the substitution [ [ (0, TInt) ] ],
   but binding [v = 0] with [ty = TFun (TVar 0, TInt)] raises [TypeError]
   because `'a0` would appear on both sides. *)
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

(* [unify t1 t2] determines the most general substitution that makes [t1] and
   [t2] structurally equal.  It works structurally: integers unify with
   integers, functions unify component-wise, and variables are bound using
   [bind_variable].  Example:
   [unify (TFun (TVar 0, TInt)) (TFun (TBool, TVar 1))] returns the substitution
   [ [ (1, TInt); (0, TBool) ] ].  Applying that substitution to both inputs
   yields the identical type [TFun (TBool, TInt)]. *)
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

(* [lookup env name] retrieves the type scheme associated with [name].
   Example: if [env = [ ("x", Forall ([], TInt)) ]], then
   [lookup env "x"] returns [Forall ([], TInt)], while looking up ["y"] raises
   a [TypeError] describing the unbound variable. *)
let lookup (env : type_env) (name : string) : type_scheme =
  match List.assoc_opt name env with
  | Some scheme -> scheme
  | None -> raise (TypeError (Printf.sprintf "Unbound variable %s" name))

(* [infer_expr env e] implements Algorithm W and returns a pair consisting of
   the accumulated substitution and the inferred type for [e] after applying
   that substitution.  The recursive cases mirror the typing rules of the
   language.  A few walkthroughs:
   - For the literal [Int 42], we get [(empty_subst, TInt)].
   - For [Let ("id", Fun ("x", Var "x"), App (Var "id", Int 1))], we produce a
     substitution describing no constraints and a final type [TInt].
   - For [If (Bool true, Int 0, Bool false)] the call to [unify] on the branches
     raises [TypeError] because the branches do not agree in type.
   The function composes substitutions in the order demanded by the algorithm
   so that later inferences see earlier equalities. *)
let rec infer_expr (tenv : type_env) (e : expr) : substitution * typ =
  match e with
  | Int _ -> (empty_subst, TInt)
  | Bool _ -> (empty_subst, TBool)
  | Var x ->
      let scheme = lookup tenv x in
      (empty_subst, instantiate scheme)
  | Let (name, e1, e2) ->
      let s1, t1 = infer_expr tenv e1 in
      let env1 = apply_subst_env s1 tenv in
      let scheme = generalize env1 t1 in
      let env2 = (name, scheme) :: env1 in
      let s2, t2 = infer_expr env2 e2 in
      let subst = compose_subst s2 s1 in
      (subst, apply_subst_type subst t2)
  | Fun (x, e) ->
      let tx = fresh_type () in
      let env' = (x, Forall ([], tx)) :: tenv in
      let se, te = infer_expr env' e in
      let tx' = apply_subst_type se tx in
      let subst = se in
      let fn_type = TFun (tx', te) in
      (subst, apply_subst_type subst fn_type)
  | App (e1, e2) ->
      let s1, t1 = infer_expr tenv e1 in
      let env1 = apply_subst_env s1 tenv in
      let s2, t2 = infer_expr env1 e2 in
      let result_type = fresh_type () in
      let s_unify =
        unify (apply_subst_type s2 t1) (TFun (t2, result_type))
      in
      let subst = compose_subst s_unify (compose_subst s2 s1) in
      (subst, apply_subst_type subst result_type)
  | _ -> failwith "Unimplemented"

(* [infer expr] is the entry point for clients.  It calls [infer_expr] with an
   initially empty environment, applies the final substitution, and returns the
   fully resolved type.  Example: on the AST for
   [Fun ("x", Fun ("y", Binop (Add, Var "x", Var "y")))] the result is
   [TFun (TInt, TFun (TInt, TInt))], meaning a two-argument integer addition
   function. *)
let infer (expr : expr) : typ =
  let subst, ty = infer_expr [] expr in
  apply_subst_type subst ty
