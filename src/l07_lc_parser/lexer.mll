{
open Parser
}

let var   = ['a'-'z' 'A'-'Z']+
let space = [' ' '\t']+

rule read =
	parse
	| space       { read lexbuf }
	| '\\' | '/'  { LAMBDA }
	| '.'         { DOT }
	| var as v    { VAR v }
	| '('         { LPAREN }
	| ')'         { RPAREN }
	| eof         { EOF }
	
