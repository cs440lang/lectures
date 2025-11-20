(** A normal-order interpreter for the untyped lambda calculus.
    Implements capture-ignoring substitution, a single-step reducer,
    and a REPL that normalizes terms via repeated beta reduction. *)

open Ast

(** [parse s] lexes and parses a lambda-calculus expression from [s],
    raising [Parser.Error] on malformed input. *)
let parse (s : string) : expr =
  let lexbuf = Lexing.from_string s in
  let ast = Parser.prog Lexer.read lexbuf in
  ast

(* Pretty-Printing ***********************************************************)

(** [string_of_expr e] renders [e] with minimal parentheses, using context
    to avoid extraneous grouping in applications. For example,
    - [string_of_expr (Abs ("x", Var "x"))] = ["λx.x"]
    - [string_of_expr (App (Var "f", App (Var "x", Var "y")))] = ["f (x y)"]. *)
let string_of_expr (e : expr) : string =
  let rec aux ctx = function
    (* ctx indicates context/precedence, used to parenthesize
     * - if ctx = 0, at top-level, no parens needed
     * - if ctx = 1, inside function application on left side
     * - if ctx = 2, inside function application on right side *)
    | Var x -> x
    | Abs (x, e) ->
        let body = aux 0 e in
        let s = Printf.sprintf "λ%s.%s" x body in
        if ctx > 0 then "(" ^ s ^ ")" else s
    | App (e1, e2) ->
        let s = Printf.sprintf "%s %s" (aux 1 e1) (aux 2 e2) in
        if ctx = 2 then "(" ^ s ^ ")" else s
  in aux 0 e

(* Substitution  *************************************************************)

(** [subst v x e] computes [[v/x]e], replacing free occurrences of [x] in [e]
    with [v]. Examples:

    - subst id "z" (Var "z") = id
    - subst id "z" (Var "y") = Var "y" 
    - subst id "z" (App (Var "w", Var "z")) = App (Var "w", id)
    - subst id "z" (App (Var "z", Var "z")) = App (id, id)
    - subst id "z" (Abs ("x", Var "z")) = Abs ("x", id)
    - subst id "z" (Abs ("z", Var "z")) = Abs ("z", Var "z") *)
let rec subst (v : expr) (x : string) (e : expr) : expr =
  match e with
  | Var y -> if x = y then v else e
  | App (e1, e2) -> App (subst v x e1, subst v x e2)
  (* Broken! Need to consider variable capture. *)
  | Abs (y, body) -> if x = y then e
                     else Abs (y, subst v x body) 

(* Evaluation ****************************************************************)

(** [step_normal e] performs one normal-order (leftmost-outermost) beta reduction.
    Returns [Some e'] when a redex is reduced and [None] when [e] is in
    normal form. Examples:

    - step_normal @@ App (id, Var "x")
                   = Some (Var "x")
    - step_normal @@ App (App (id, id), App (id, id))
                   = Some (App (id, App (id, id)))
    - step_normal @@ App (Var "x", App (id, id))
                   = Some (App (Var "x", id))
    - step_normal @@ Abs ("x", App (id, Var "x"))
                   = Some (Abs ("x", Var "x"))
    - step_normal @@ Var "x"
                   = None
    - step_normal @@ App (Var "x", Var "y")
                   = None
    - step_normal @@ Abs ("x", App (Var "x", Var "y"))
                   = None *)
let rec step_normal : expr -> expr option = function
  | App (Abs (x, e1), e2) ->
      Some (subst e2 x e1)                    (* beta reduction *)
  | App (e1, e2) -> (
      match step_normal e1 with
      | Some e1' -> Some (App (e1', e2))      (* reduce left first *)
      | None -> (
          match step_normal e2 with
          | Some e2' -> Some (App (e1, e2'))  (* then reduce right *)
          | None -> None))
  | Abs (x, e) -> (
       match step_normal e with
       | Some e' -> Some (Abs (x, e'))
       | None -> None)
  | Var _ -> None

(** [eval_normal ?trace e] repeatedly applies [step_normal] until no redexes
    remain, returning the resulting normal form. When [trace] is true, each
    intermediate term is printed. *)
let rec eval_normal ?(trace=false) (e : expr) : expr =
  if trace then print_endline (string_of_expr e) ;
  match step_normal e with
  | Some e' -> eval_normal ~trace e'
  | None -> e

(* REPL **********************************************************************)

(** [repl ?trace ()] runs a read-eval-print loop for the lambda calculus,
    parsing input lines, evaluating them to normal form, and printing the
    result; blank input exits. *)
let rec repl ?(trace=false) () =
  print_string "> ";
  flush stdout;
  match read_line () with
  | "" -> ()
  | line -> (
      try
        let expr = parse line in
        let value = eval_normal ~trace expr in
        print_endline (string_of_expr value);
        repl ()
      with
      | Failure msg ->
          Printf.printf "Error: %s\n" msg;
          repl ()
      | Parser.Error ->
          print_endline "Parse error.";
          repl ())
