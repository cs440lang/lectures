(* ============================================================================
 * Converts a character stream into tokens expected by the parser:
 *
 *   Tokens:
 *     LAMBDA    -- '\'
 *     DOT       -- '.'
 *     LPAREN    -- '('
 *     RPAREN    -- ')'
 *     IDENT s   -- variable name
 *     EOF       -- end of input
 *
 *   Correspondence with grammar nonterminals:
 *     λ<var>.<expr>     ->  LAMBDA IDENT DOT ...
 *     ( <expr> )        ->  LPAREN ... RPAREN
 *     <var>             ->  IDENT
 *
 * Whitespace is ignored (spaces, tabs, newlines).
 *
 * Example tokenization:
 *
 *   Input:  \x.(x y)
 *   Tokens: [LAMBDA; IDENT "x"; DOT; LPAREN; IDENT "x"; IDENT "y"; RPAREN; EOF]
 *
 *   Input:  (\x.x) y
 *   Tokens: [LPAREN; LAMBDA; IDENT "x"; DOT; IDENT "x"; RPAREN; IDENT "y"; EOF]
 * ============================================================================
 *)

{
open Parser
}

let ident = ['a'-'z' 'A'-'Z']+
let space = [' ' '\t']+

rule read =
	parse
	| space       { read lexbuf }
	| '\\'        { LAMBDA }
	| '.'         { DOT }
	| ident as s  { IDENT s }
	| '('         { LPAREN }
	| ')'         { RPAREN }
	| eof         { EOF }
	
