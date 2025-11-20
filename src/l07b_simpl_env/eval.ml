(** An environment-based variant of the SimPL interpreter. Replaces
    substitution with an explicit environment, illustrating big-step
    evaluation with state threaded through function calls. *)

open Ast

(** [parse s] lexes and parses a simple expression with variables from [s],
    raising [Parser.Error] on malformed input. *)
let parse (s : string) : expr =
  let lexbuf = Lexing.from_string s in
  let ast = Parser.prog Lexer.read lexbuf in
  ast

type value = VInt of int | VBool of bool
(** Values produced by interpretation. *)

(** [string_of_val v] renders a run-time [value] for display in the REPL. *)
let string_of_val : value -> string = function
  | VInt n -> string_of_int n
  | VBool b -> string_of_bool b

type env = (string * value) list
(** Environment mapping identifiers to their run-time values. Newer bindings
    appear earlier in the list. *)

exception RuntimeError of string
(** Raised when evaluation encounters an ill-formed operation or unbound
    variable. *)

(** [eval e env] evaluates [e] under environment [env] using big-step
    semantics. *)
let rec eval (e : expr) (env: env) : value =
  match e with
  | Int i -> VInt i
  | Bool b -> VBool b
  | Var x -> (
      match List.assoc_opt x env with
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

(** [repl ()] runs the interactive interpreter: it parses a line, evaluates
    it in the empty environment, prints the resulting value, and repeats until
    a blank line is provided. *)
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
