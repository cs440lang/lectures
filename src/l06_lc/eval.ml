open Ast

let parse (s : string) : expr =
  let lexbuf = Lexing.from_string s in
  let ast = Parser.prog Lexer.read lexbuf in
  ast

let string_of_expr (e : expr) : string =
  let rec aux ctx = function
    (* ctx indicates context/precedence, used to parenthesize
     * - if ctx = 0, at top-level, no parens needed
     * - if ctx = 1, inside function application on left side
     * - if ctx = 2, inside function application on right side *)
    | Var x -> x
    | Abs (x, e) ->
        let body = aux 0 e in
        let s = Printf.sprintf "λ%s.%s" x body in
        if ctx > 0 then "(" ^ s ^ ")" else s
    | App (e1, e2) ->
        let s = Printf.sprintf "%s %s" (aux 1 e1) (aux 2 e2) in
        if ctx = 2 then "(" ^ s ^ ")" else s
  in aux 0 e

(* subst v x e = [v/x] e
 * e.g.,
 * - subst id "z" (Var "z") = id
 * - subst id "z" (Var "y") = Var "y" 
 * - subst id "z" (App (Var "w", Var "z")) = App (Var "w", id)
 * - subst id "z" (App (Var "z", Var "z")) = App (id, id)
 * - subst id "z" (Abs ("x", Var "z")) = Abs ("x", id)
 * - subst id "z" (Abs ("z", Var "z")) = Abs ("z", Var "z")
 *)
let rec subst v x e = failwith "undefined"
  
(* normal-order (leftmost-outermost) step function
 * - if a redex exists in arg e, perform it and return Some e'
 * - else return None 
 *
 * e.g.,
 * - step_normal @@ App (id, Var "x")
 *                = Some (Var "x")
 * - step_normal @@ App (App (id, id), App (id, id))
 *                = Some (App (id, App (id, id)))
 * - step_normal @@ App (Var "x", App (id, id))
 *                = Some (App (Var "x", id))
 * - step_normal @@ Abs ("x", App (id, Var "x"))
 *                = Some (Abs ("x", Var "x"))
 * - step_normal @@ Var "x"
 *                = None
 * - step_normal @@ App (Var "x", Var "y")
 *                = None
 * - step_normal @@ Abs ("x", App (Var "x", Var "y"))
 *                = None
 *)
let rec step_normal e = failwith "undefined"

(* normal-order multi-step eval
 * - step until no more redexes remain, return resulting expr *)
let rec eval_normal e = failwith "undefined"

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
        let value = eval_normal expr in
        print_endline (string_of_expr value);
        repl ()
      with
      | Failure msg ->
          Printf.printf "Error: %s\n" msg;
          repl ()
      | Parser.Error ->
          print_endline "Parse error.";
          repl ())
