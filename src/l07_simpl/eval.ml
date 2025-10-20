open Ast

let parse (s : string) : expr =
  let lexbuf = Lexing.from_string s in
  let ast = Parser.prog Lexer.read lexbuf in
  ast

let rec string_of_expr : expr -> string = function
  | Int n -> string_of_int n
  | Bool b -> string_of_bool b
  | Var x -> x
  | Binop (bop, e1, e2) ->
      Printf.sprintf "(%s %s %s)" (string_of_expr e1)
        (match bop with Add -> "+" | Mult -> "*" | Leq -> "<=")
        (string_of_expr e2)
  | If (e1, e2, e3) ->
      Printf.sprintf "(if %s then %s else %s)" (string_of_expr e1)
        (string_of_expr e2) (string_of_expr e3)
  | Let (x, e1, e2) ->
      Printf.sprintf "(let %s = %s in %s)" x (string_of_expr e1)
        (string_of_expr e2)

(* subst v x e = [v/x] e *)
let rec subst (v : expr) (x : string) (e : expr) : expr =
  match e with
  | Bool _ -> e
  | Int _ -> e
  | Var y -> if x = y then v else e
  | Binop (bop, e1, e2) -> Binop (bop, subst v x e1, subst v x e2)
  | If (e1, e2, e3) -> If (subst v x e1, subst v x e2, subst v x e3)
  | Let (y, e1, e2) ->
      let e1' = subst v x e1 in
      if x = y then Let (y, e1', e2) else Let (y, e1', subst v x e2)

(* small-step reduction of a given expression e;
   returns Some e' if a redex exists, None otherwise *)
let rec step : expr -> expr option = function
  | Int _ | Bool _ | Var _ -> None
  | Binop (bop, e1, e2) -> (
      match step e1 with
      | Some e1' -> Some (Binop (bop, e1', e2))
      | None -> (
          match step e2 with
          | Some e2' -> Some (Binop (bop, e1, e2'))
          | None -> (
              match (bop, e1, e2) with
              | Add, Int a, Int b -> Some (Int (a + b))
              | Mult, Int a, Int b -> Some (Int (a * b))
              | Leq, Int a, Int b -> Some (Bool (a <= b))
              | _ -> failwith "Invalid bop")))
  | If (b, e1, e2) -> (
      match step b with
      | Some b' -> Some (If (b', e1, e2))
      | None -> (
          match b with
          | Bool true -> Some e1
          | Bool false -> Some e2
          | _ -> failwith "Invalid guard"))
  | Let (x, e1, e2) -> (
      match step e1 with
      | Some e1' -> Some (Let (x, e1', e2))
      | None -> Some (subst e1 x e2))

(* single-step reduce until we get a value *)
let rec eval (e : expr) : expr =
  print_endline (string_of_expr e);
  match step e with None -> e | Some e' -> eval e'

(* big-step reduction *)
let rec eval' (e : expr) : expr =
  match e with
  | Int _ | Bool _ -> e
  | Var _ -> failwith "Unbound variable"
  | Binop (bop, e1, e2) -> (
      match (bop, eval' e1, eval' e2) with
      | Add, Int a, Int b -> Int (a + b)
      | Mult, Int a, Int b -> Int (a * b)
      | Leq, Int a, Int b -> Bool (a <= b)
      | _ -> failwith "Invalid bop")
  | If (e1, e2, e3) -> (
      match eval' e1 with
      | Bool true -> eval' e2
      | Bool false -> eval' e3
      | _ -> failwith "Invalid guard")
  | Let (x, e1, e2) -> eval' (subst (eval' e1) x e2)

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
        let value = eval expr in
        print_endline (string_of_expr value);
        repl ()
      with
      | Failure msg ->
          Printf.printf "Error: %s\n" msg;
          repl ()
      | Parser.Error ->
          print_endline "Parse error.";
          repl ())
