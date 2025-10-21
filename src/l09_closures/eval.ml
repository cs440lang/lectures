open Ast

let parse (s : string) : expr =
  let lexbuf = Lexing.from_string s in
  let ast = Parser.prog Lexer.read lexbuf in
  ast

(* adding closures as a value type, which contains
   - a bound variable,
   - an expression (the body),
   - and an environment  *)
type env = (string * value) list
and value = VInt of int
          | VBool of bool
          | Closure of (string * expr * env) 

let string_of_val : value -> string = function
  | VInt n -> string_of_int n
  | VBool b -> string_of_bool b
  | Closure _ -> "<fn>"

(* for easily switching between scoping strategy,
   as applied to functions *)
type scope_rule = Lexical | Dynamic
let scope = Lexical

let rec eval (e : expr) (env: env) : value =
  match e with
  | Int i -> VInt i
  | Bool b -> VBool b
  | Var v -> List.assoc v env
  | Binop (bop, e1, e2) -> (
      match (bop, eval e1 env, eval e2 env) with
      | Add, VInt a, VInt b -> VInt (a + b)
      | Mult, VInt a, VInt b -> VInt (a * b)
      | Leq, VInt a, VInt b -> VBool (a <= b)
      | _ -> failwith "Invalid bop")
  | If (e1, e2, e3) -> (
      match eval e1 env with
      | VBool true -> eval e2 env
      | VBool false -> eval e3 env
      | _ -> failwith "Invalid guard")
  | Let (x, e1, e2) -> eval e2 ((x, eval e1 env) :: env)

  (* evaluating a function should give us a closure *)
  | Fun (x, body) -> failwith "undefined"

  (* application requires a closure on the left,
     whose body is evaluated with its variable
     bound to the argument in the environment *)
  | App (e1, e2) -> failwith "undefined"

(* Read a line and Parse an expression out of it,
   Evaluate it to a value,
   Print the value,
   Loop  *)
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
      | Failure msg ->
          Printf.printf "Error: %s\n" msg;
          repl ()
      | Parser.Error ->
          print_endline "Parse error.";
          repl ())
