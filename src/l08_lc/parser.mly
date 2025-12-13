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
 *   <expr>   ::= λ<var>.<expr> | <app>
 *   <app>    ::= <app> <apparg> | <atom>
 *   <apparg> ::= <atom> | λ<var>.<expr>
 *   <atom>   ::= <var> | ( <expr> )
 *
 *   - Application (<app>) is left-recursive -> left-associative
 *       "f x y" ≡ ((f x) y)
 *
 *   - Abstraction (λ<var>.<expr>) is right-associative by structure
 *       "λx.λy.x" ≡ λx.(λy.x)
 *
 *   - Lambda abstractions can appear as application arguments without parens
 *       "x λy.y" ≡ x (λy.y) 
 *
 *   - Parentheses group explicitly and override associativity
 *
 * Example parses:
 *   λx.x       ->  Abs ("x", Var "x")
 *   (λx.x) y   ->  App (Abs ("x", Var "x"), Var "y")
 *   x (λy.y)   ->  App (Var "x", Abs ("y", Var "y"))
 *   x λy.y     ->  App (Var "x", Abs ("y", Var "y"))  [same as above]
 *   λx.λy.x y  ->  Abs ("x", Abs ("y", App (Var "x", Var "y")))
 *
 * Note: This grammar has shift/reduce conflicts that Menhir resolves by
 * preferring to shift (extend applications). This gives correct behavior:
 * lambda bodies extend as far right as possible.
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
  | f=app arg=apparg                { App (f, arg) }
  | e=atom                          { e }

/* Application arguments:
 *   - An atom (variable or parenthesized expression)
 *   - A lambda abstraction (allows "x λy.y" without parens)
 */
apparg:
  | e=atom                          { e }
  | LAMBDA id=IDENT DOT body=expr   { Abs (id, body) }

/* Atomic expressions:
 *   - A variable
 *   - A parenthesized expression
 */
atom:
  | id=IDENT                        { Var id }
  | LPAREN e=expr RPAREN            { e }
