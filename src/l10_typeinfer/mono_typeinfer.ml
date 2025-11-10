open Ast

(* This module implements a monomorphic variant of the type inference
   machinery used in lecture. It mirrors the structure of the polymorphic
   algorithm but drops generalisation/instantiation so that students can trace
   constraint generation and unification in a simpler setting.  The REPL at the
   bottom prints the raw constraints before solving, making it convenient for
   hand-simulating each example discussed in class. *)

exception TypeError of string

type type_variable = int
type typ = TInt | TBool | TFun of typ * typ | TVar of type_variable
type type_env = (string * typ) list
type type_constraint = typ * typ
type substitution = (type_variable * typ) list

(* Fresh type variables ******************************************************)

(* [fresh_int ()] supplies globally fresh integers; [fresh_var ()] wraps them
   as type variables such as ['a3]. *)
let fresh_int =
  let counter = ref 0 in
  fun () ->
    let v = !counter in
    incr counter;
    v

let fresh_var () = TVar (fresh_int ())

(* Pretty printing ***********************************************************)

(* [string_of_type ty] renders [ty] in OCaml syntax, e.g.
   [string_of_type (TFun (TInt, TVar 0))] = ["int -> 'a0"]. *)
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

(* [string_of_constraint (lhs, rhs)] shows a single equation such as
   ["'a0 -> int ~ bool"]. *)
let string_of_constraint (lhs, rhs) =
  Printf.sprintf "%s = %s" (string_of_type lhs) (string_of_type rhs)

(* [string_of_subst subst] pretty-prints the substitution, one binding per
   line, e.g. [[ (0, TInt); (1, TBool) ]] becomes:
   {'a0 = int
    'a1 = bool}. *)
let rec string_of_subst = function
  | [] -> ""
  | (n, typ) :: ss ->
      let s = Printf.sprintf "'a%d ↦ %s\n" n (string_of_type typ) in
      s ^ string_of_subst ss

(* Constraint generation *****************************************************)

(* [lookup env x] finds the monomorphic type of [x] or raises a helpful error
   if [x] is unbound. *)
let lookup (tenv : type_env) (name : string) : typ =
  match List.assoc_opt name tenv with
  | Some typ -> typ
  | None -> raise (TypeError (Printf.sprintf "Unbound variable %s" name))

(* [collect_constraints_expr env e] walks [e], produces a raw type, and the
   list of constraints needed to justify that type. All unifications are
   deferred so that students can see the full system. *)
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
      let constraints = c1 @ c2 @ c3 @ [ (t1, TBool); (t, t2); (t, t3) ] in
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
      let constraints = c1 @ c2 @ [ (t1, TFun (t2, t)) ] in
      (t, constraints)

(* Substitutions *************************************************************)

let empty_subst : substitution = []

(* [apply_subst_type subst ty] replaces every variable mentioned in [subst]
   throughout [ty].  Example: applying [[ (0, TInt) ]] to
   [TFun (TVar 0, TVar 1)] results in [TFun (TInt, TVar 1)]. *)
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

(* Unification ***************************************************************)

(* [occurs v ty] implements the occurs check: it returns [true] if [v] appears
   somewhere inside [ty], preventing equations such as ['a = 'a -> 'b]. *)
let rec occurs (v : type_variable) = function
  | TInt | TBool -> false
  | TVar v' -> v = v'
  | TFun (t1, t2) -> occurs v t1 || occurs v t2

(* [bind_variable v ty] produces the substitution linking [v] with [ty],
   while refusing to construct infinite types.  Example:
   [bind_variable 0 TInt] = [[ (0, TInt) ]]. *)
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

(* [unify t1 t2] computes the substitution that makes [t1] and [t2] equal.
   Example: unifying [TFun (TVar 0, TInt)] with [TFun (TBool, TVar 1)] yields
   [[ (1, TInt); (0, TBool) ]]. *)
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

(* [solve_constraints constraints] folds [unify] over the constraint list,
   showing the order in which Algorithm W would solve them by hand.  Using
   [[ (TVar 0, TInt); (TVar 0, TVar 1) ]] produces the substitution
   [[ (1, TInt); (0, TInt) ]]. *)
let solve_constraints (constraints : type_constraint list) : substitution =
  List.fold_left
    (fun subst (lhs, rhs) ->
      let lhs' = apply_subst_type subst lhs in
      let rhs' = apply_subst_type subst rhs in
      let new_subst = unify lhs' rhs' in
      compose_subst new_subst subst)
    empty_subst constraints

(* A REPL that prints out the raw type and constraints for each expression
   entered so we can double-check / attempt unification. By default, it
   will not show the "solved" final type. To get it to do so, call it
   like so: [repl ~solve:true ()]*)
let rec repl ?(solve=false) () =
  print_string "> ";
  flush stdout;
  match read_line () with
  | "" -> ()
  | line -> (
      try
        let e = Eval.parse line in
        let raw_type, constraints = collect_constraints_expr [] e in
        if constraints <> [] then (
          Printf.printf "Raw type: %s\n" (string_of_type raw_type);
          print_endline "Constraints:";
          List.iteri
            (fun idx constraint_eq ->
              Printf.printf "C%d: %s\n" (idx + 1)
                (string_of_constraint constraint_eq))
            constraints);
        if solve then (
          let subst = solve_constraints constraints in
          let typ = apply_subst_type subst raw_type in
          print_endline "Substitutions:";
          print_string (string_of_subst subst);
          Printf.printf "- : %s\n" (string_of_type typ)
        );
        repl ~solve:solve ()
      with TypeError msg ->
        print_endline msg;
        repl ~solve:solve ())
