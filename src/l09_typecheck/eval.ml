open Ast
open Typecheck

let parse (s : string) : expr =
  let lexbuf = Lexing.from_string s in
  let ast = Parser.prog Lexer.read lexbuf in
  ast

type env = (string * value) list
and value = VInt of int
          | VBool of bool
          | Closure of (string * expr * env) 

let string_of_val : value -> string = function
  | VInt n -> string_of_int n
  | VBool b -> string_of_bool b
  | Closure _ -> "<fun>"

exception RuntimeError of string

let rec eval (e : expr) (env: env) : value =
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
      | _ -> raise (RuntimeError "Invalid bop args"))
  | If (e1, e2, e3) -> (
      match eval e1 env with
      | VBool true -> eval e2 env
      | VBool false -> eval e3 env
      | _ -> raise (RuntimeError "Invalid guard"))
  | Let (x, e1, e2) -> eval e2 ((x, eval e1 env) :: env)
  | Fun (x, _, body) -> Closure (x, body, env)
  | App (e1, e2) -> (
      match eval e1 env with
      | Closure (x, body, defenv) -> 
          let arg = eval e2 env in
          eval body ((x, arg) :: defenv)
      | _ -> raise (RuntimeError "Invalid application"))

let rec repl () =
  print_string "> ";
  flush stdout;
  match read_line () with
  | "" -> ()
  | line -> (
      try
        let expr = parse line in
        (* type-checking before evaluation *)
        let typ = typeof expr [] in
        let value = eval expr [] in
        Printf.printf "- : %s = %s\n"
          (string_of_type typ)
          (string_of_val value);
        repl ()
      with
      | TypeError msg ->
          Printf.printf "Type Error: %s\n" msg;
          repl ()
      | RuntimeError msg ->
          Printf.printf "Runtime Error: %s\n" msg;
          repl ()
      | Parser.Error ->
          print_endline "Parse error.";
          repl ())
