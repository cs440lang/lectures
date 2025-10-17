/* ============================================================================
 * This parser produces values of type [Ast.expr], defined as:
 *
 *   type expr =
 *     | Var of string
 *     | Abs of string * expr
 *     | App of expr * expr
 *
 * The rules below implement this BNF:
 *
 *   <expr> ::= λ<var>.<expr> | <app>
 *   <app>  ::= <app> <atom> | <atom>
 *   <atom> ::= <var> | ( <expr> )
 *
 *   - Application (<app>) is left-recursive -> left-associative
 *       "f x y" ≡ ((f x) y)
 *
 *   - Abstraction (λ<var>.<expr>) is right-associative by structure
 *       "λx.λy.x" ≡ λx.(λy.x)
 *
 *   - Parentheses group explicitly and override associativity
 *
 * Example parses:
 *   λx.x       ->  Abs ("x", Var "x")
 *   (λx.x) y   ->  App (Abs ("x", Var "x"), Var "y")
 *   x (λy.y)   ->  App (Var "x", Abs ("y", Var "y"))
 *   λx.λy.x y  ->  Abs ("x", Abs ("y", App (Var "x", Var "y")))
 * ============================================================================
 */

%{
open Ast
%}

%token LAMBDA
%token DOT
%token <string> IDENT
%token LPAREN
%token RPAREN
%token EOF

%start <Ast.expr> prog

%%

/* Entry point: parse a full expression until EOF */
prog: e=expr EOF                    { e }

/* An expression is either:
 *   - a lambda abstraction (λ var. expr), or
 *   - an application sequence
 */
expr:
  | LAMBDA id=IDENT DOT body=expr   { Abs (id, body) }
  | e=app                           { e }

/* Application:
 *   - Left-recursive rule ensures left-associative parsing
 *     (e.g., "f x y" = ((f x) y))
 */
app:
  | f=app arg=atom                  { App (f, arg) }
  | e=atom                          { e }

/* Atomic expressions:
 *   - A variable
 *   - A parenthesized expression
 */
atom:
  | id=IDENT                        { Var id }
  | LPAREN e=expr RPAREN            { e }
