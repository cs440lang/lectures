%{
open Ast

let curry (args: ((string*typ) list)) (body: expr) : expr =
  List.fold_right (fun (x,t) body -> Fun (x, t, body))
                  args body
%}

%token <int> INT
%token <string> ID
%token TRUE FALSE
%token LEQ TIMES PLUS
%token LPAREN RPAREN
%token LET EQUALS IN
%token IF THEN ELSE
%token FUN ARROW
%token COLON
%token TINT TBOOL
%token EOF

%start <Ast.expr> prog

%%

prog:
  e = expr; EOF { e }

expr:
  | LET x = ID EQUALS e1 = expr IN e2 = expr
      { Let (x, e1, e2) }
  | IF e1 = expr THEN e2 = expr ELSE e3 = expr
      { If (e1, e2, e3) }
  | FUN xs = nonempty_list(arg) ARROW e = expr
      { curry xs e }
  | e = binop_expr
      { e }

arg:
  | x = ID COLON t = atomic_typ
      { (x,t) }

typ:
  | t1 = atomic_typ ARROW t2 = typ { TFun (t1, t2) }
  | t = atomic_typ { t }

atomic_typ:
  | TINT { TInt }
  | TBOOL { TBool }
  | LPAREN t = typ RPAREN { t }

binop_expr:
  | e1 = binop_expr PLUS e2 = app_expr
      { Binop (Add, e1, e2) }
  | e1 = binop_expr TIMES e2 = app_expr
      { Binop (Mult, e1, e2) }
  | e1 = binop_expr LEQ e2 = app_expr
      { Binop (Leq, e1, e2) }
  | e = app_expr
      { e }

app_expr:
  | f = app_expr arg = atom
      { App (f, arg) }
  | e = atom
      { e }

atom:
  | i = INT { Int i }
  | TRUE { Bool true }
  | FALSE { Bool false }
  | x = ID { Var x }
  | LPAREN e = expr RPAREN { e }
