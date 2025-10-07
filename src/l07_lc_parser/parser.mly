%{
open Ast
%}

%token LAMBDA
%token DOT
%token <string> VAR
%token LPAREN
%token RPAREN
%token EOF

%start <Ast.expr> prog

%%

prog:
  | e=expr EOF                     { e }

expr:
  | LAMBDA v=VAR DOT body=expr     { Abs (v, body) }
  | e = app                        { e }

app:
  | f=app arg=atom                 { App (f, arg) }
  | e=atom                         { e }

atom:
  | v=VAR                          { Var v }
  | LPAREN e=expr RPAREN           { e }
