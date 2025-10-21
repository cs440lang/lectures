open Ast

let parse (s : string) : expr =
  let lexbuf = Lexing.from_string s in
  let ast = Parser.prog Lexer.read lexbuf in
  ast

(* type representing an evaluated value  *)
type value = VInt of int | VBool of bool

let string_of_val : value -> string = function
  | VInt n -> string_of_int n
  | VBool b -> string_of_bool b

(* we represent an environment as an associative list
   of name-value mappings  *)
type env = (string * value) list

(* big-step evaluation using an environment *)
let rec eval (e : expr) (env: env) : value =
  match e with
  | Int i -> VInt i
  | Bool b -> VBool b
  | Var v -> failwith "undefined"
  | Binop (bop, e1, e2) -> failwith "undefined"
  | If (e1, e2, e3) -> failwith "undefined"
  | Let (x, e1, e2) -> failwith "undefined"

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
