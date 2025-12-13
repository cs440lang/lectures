
(* The type of tokens. *)

type token = 
  | RPAREN
  | LPAREN
  | LAMBDA
  | IDENT of (string)
  | EOF
  | DOT

(* This exception is raised by the monolithic API functions. *)

exception Error

(* The monolithic API. *)

val prog: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (Ast.expr)
