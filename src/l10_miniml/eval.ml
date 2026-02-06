(** A MiniML interpreter with first-class functions and closures.
    Extends the environment-based core with lexical vs. dynamic scoping
    (configurable), capturing environments in closures to implement
    higher-order functions. *)

open Ast

(** [parse s] lexes and parses a MiniML expression from [s], raising
    [Parser.Error] on malformed input. *)
let parse (s : string) : expr =
  let lexbuf = Lexing.from_string s in
  let ast = Parser.prog Lexer.read lexbuf in
  ast

type env = (string * value) list
(** Environment mapping variable names to run-time values; newer bindings shadow
    older ones. *)

and value = VInt of int | VBool of bool | Closure of (string * expr * env)

(** [string_of_val v] renders a run-time value, using ["<fun>"] for closures to
    avoid printing environments. *)
let string_of_val : value -> string = function
  | VInt n -> string_of_int n
  | VBool b -> string_of_bool b
  | Closure _ -> "<fun>"

(** Scoping strategy for functions: [Lexical] uses the defining environment
    (standard lexical scope); [Dynamic] uses the call-site environment. *)
type scope_rule = Lexical | Dynamic

let scope = Lexical

exception RuntimeError of string

(** [eval e env] evaluates [e] under environment [env], constructing closures
    for [Fun] and applying them with the chosen [scope]. *)
let rec eval (e : expr) (env : env) : value =
  match e with
  | Int i -> VInt i
  | Bool b -> VBool b
  | Var v -> (
      match List.assoc_opt v env with
      | Some y -> y
      | None -> raise (RuntimeError "Unbound variable"))
  | Binop (bop, e1, e2) -> (
      match (bop, eval e1 env, eval e2 env) with
      | Add, VInt a, VInt b -> VInt (a + b)
      | Mult, VInt a, VInt b -> VInt (a * b)
      | Leq, VInt a, VInt b -> VBool (a <= b)
      | _ -> raise (RuntimeError "Invalid bop"))
  | If (e1, e2, e3) -> (
      match eval e1 env with
      | VBool true -> eval e2 env
      | VBool false -> eval e3 env
      | _ -> raise (RuntimeError "Invalid guard"))
  | Let (x, e1, e2) -> eval e2 ((x, eval e1 env) :: env)
  (* evaluating a function gives us a closure *)
  | Fun (x, body) -> Closure (x, body, env)
  (* application requires a closure on the left,
     whose body is evaluated with its variable
     bound to the argument in the environment *)
  | App (e1, e2) -> (
      match eval e1 env with
      | Closure (x, body, defenv) ->
          let arg = eval e2 env in
          let base_env =
            match scope with Lexical -> defenv | Dynamic -> env
          in
          let cenv = (x, arg) :: base_env in
          eval body cenv
      | _ -> raise (RuntimeError "Invalid application"))

(** [repl ()] runs a MiniML read-eval-print loop in the empty environment until
    a blank line is entered. *)
let rec repl () =
  print_string "> ";
  flush stdout;
  match read_line () with
  | "" -> ()
  | line -> (
      try
        let expr = parse line in
        let value = eval expr [] in
        print_endline (string_of_val value);
        repl ()
      with
      | RuntimeError msg ->
          Printf.printf "Runtime Error: %s\n" msg;
          repl ()
      | Parser.Error ->
          print_endline "Parse error.";
          repl ())
