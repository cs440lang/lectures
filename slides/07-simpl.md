---
title: "SimPL and Operational Semantics"
author: "Michael Lee"
theme:
  override:
    typst:
      colors:
        foreground: ffffff
        background: 000000
---

# Agenda

- SimPL
- Operational Semantics
  - Rules of Inference
  - Assertions / Judgements
- Substitution Model Evaluation
- Environment Model Evaluation

---

# SimPL

Time to build an interpreter for a more complex language!

<!-- pause -->

Here's our target BNF:

```
<expr>  ::= <int> | <bool> | <var>
          | <expr> <bop> <expr>
          | if <expr> then <expr> else <expr>
          | let <var> = <expr> in <expr>

<int>  ::= '-'? [0-9]+
<bool> ::= true | false
<var>  ::= [a-zA-Z]+
<bop>  ::= + | * | <=
```

---

# SimPL AST Representation

OCaml ADTs:

```ocaml
type bop =
  | Add
  | Mult
  | Leq

type expr =
  | Int of int
  | Bool of bool
  | Var of string
  | Binop of bop * expr * expr
  | If of expr * expr * expr
  | Let of string * expr * expr
```

---

# Parsing SimPL

We provide an `ocamllex`/`menhir` front-end, so:

```ocaml
# Eval.parse "5 + -2";;
- : expr = Binop (Add, Int 5, Int (-2))

# Eval.parse "100 * if 5 <= 10 then 1 else 2";;
- : expr = Binop (Mult, Int 100,
                  If (Binop (Leq, Int 5, Int 10),
                      Int 1, Int 2))

# Eval.parse "let x=5 in let y=10 in x+y";;
- : expr = Let ("x", Int 5,
                Let ("y", Int 10,
                     Binop (Add, Var "x", Var "y")))
```

---

# Evaluating SimPL

SimPL is much more complex than λ-Calculus, so we won't jump straight to code!

<!-- pause -->

First, we will *formally describe the semantics* of SimPL so that:

- the expected behavior is unambiguously understood

- the specification can guide our implementation

<!-- pause -->

How do we formally describe the semantics of a language?

---

# Operational Semantics

*Operational semantics* specifies the behavior of programming language
constructs using *rules of inference*, which describe how expressions/statements
reduce or transition to simpler forms or values.

<!-- pause -->

<!-- list_item_newlines: 1 -->

- *Small-step* semantics: describes individual computational steps, showing how
  expressions reduce to simpler forms. E.g., we might assert:

```typst +render +width:60%
$e --> e' --> e'' -->  ... --> v quad "or" quad e ~> v$
```

<!-- pause -->

- *Big-step* semantics: describes entire evaluations, relating expressions
  directly to their final results. E.g., we might assert:

```typst +render +width:10%
$e arrow.b.double v$
```

---

# Operational Semantics

## Rules of Inference

Take the form:

```typst +render +width:70%
$ "NAME" ("premise"_1 quad "premise"_2 quad ... quad "premise"_n)
         / ("conclusion") $
```

<!-- incremental_lists: true -->

- premises and the conclusion are assertions (aka "judgements") about language
  constructs

- if all premises hold, then the conclusion holds

  - rules with no premises are *axioms*

---

# Operational Semantics

## Assertions / Judgements

```typst +render +width:80%
#let bstep = sym.arrow.b.double
$
e -> e'      & wide e "reduces to" e' "in one step" \
e cancel(->) & wide e "cannot be further reduced"\
e ~> v       & wide e "reduces to" v "in zero or more steps" \
e bstep v    & wide e "evaluates to" v\
e : t        & wide e "has type" t
$
```

---

# Substitution Model Evaluation

Let's describe the semantics of SimPL using *substitution*.

- i.e., we substitute values for variable names throughout an expression, just
  like `[v/x]e` in λ-calculus

<!-- pause -->

```ocaml
let rec subst (v : expr) (x : string) (e : expr) : expr =
  match e with
  | Int _  -> e
  | Bool _ -> e
  | Var y  -> if x = y then v else e
  | Binop (bop, e1, e2) ->
      Binop (bop, subst v x e1, subst v x e2)
  | If (e1, e2, e3) ->
      If (subst v x e1, subst v x e2, subst v x e3)
  | Let (y, e1, e2) ->
      let e1' = subst v x e1 in
      if x = y then Let (y, e1', e2)
      else Let (y, e1', subst v x e2)
```

---

# Substitution Model Evaluation

## Small-Step Semantics

<!-- pause -->

### Values

<!-- pause -->

Values cannot be further reduced!

```typst +render +width:70%
$
"INT" (i : "int") / (i cancel(->)) wide

"BOOL" (b : "bool") / (b cancel(->)) wide
$
```

<!-- pause -->

```ocaml
let rec step : expr -> expr option = function
  | Int _  -> None
  | Bool _ -> None
```

---

# Substitution Model Evaluation

## Small-Step Semantics

### Binary Operations

```typst +render +width:60%
$
#let bop = sym.plus.circle

"BOP-L" & (e_1 -> e'_1) / (e_1 bop e_2 -> e'_1 bop e_2) \
$
```

<!-- pause -->

```ocaml
let rec step : expr -> expr option = function
  | Binop (bop, e1, e2) -> (
      match step e1 with
      | Some e1' -> Some (Binop (bop, e1', e2)))
```

---
# Substitution Model Evaluation

## Small-Step Semantics

### Binary Operations

```typst +render +width:60%
$
#let bop = sym.plus.circle

"BOP-R" & (e_1 cancel(->) quad e_2 -> e'_2) /
        (e_1 bop e_2 -> e_1 bop e'_2) \
$
```

<!-- pause -->

```ocaml
let rec step : expr -> expr option = function
  | Binop (bop, e1, e2) -> (
      match step e1 with
      | Some e1' -> Some (Binop (bop, e1', e2))
      | None -> (
          match step e2 with
          | Some e2' -> Some (Binop (bop, e1, e2'))))
```
---

# Substitution Model Evaluation

## Small-Step Semantics

### Binary Operations

```typst +render +width:75%
$
#let bop = sym.plus.circle

"BOP-E" & (e_1  cancel(->) quad e_2 cancel(->) quad r = e_1 bop e_2) /
        (e_1 bop e_2 -> r)
$
```

<!-- pause -->

```ocaml
match (bop, e1, e2) with
| Add,  Int a, Int b -> Some (Int (a + b))
| Mult, Int a, Int b -> Some (Int (a * b))
| Leq,  Int a, Int b -> Some (Bool (a <= b))
| _ -> failwith "Invalid operands"
```

---

# Substitution Model Evaluation

## Small-Step Semantics

### If

Can you write the rule(s) for `if-then-else` expressions?

```typst +render +width:60%
$
"IF" & (?)
       /("if" e_1 "then" e_2 "else" e_3 -> thick ?) 
$
```

---

# Substitution Model Evaluation

## Small-Step Semantics

### If

Three rules:

```typst +render +width:90%
$
"IF-G" & (e_1 -> e'_1)/
         ("if" e_1 "then" e_2 "else" e_3 -> "if" e'_1 "then" e_2 "else" e_3) \ \

"IF-T" & () / ("if true then" e_2 "else" e_3 -> e_2) \ \

"IF-F" & () / ("if false then" e_2 "else" e_3 -> e_3)
$
```

---

# Substitution Model Evaluation

## Small-Step Semantics

### If

```ocaml
let rec step : expr -> expr option = function
  | If (e1, e2, e3) -> (
      match step e1 with
      | Some e1' -> Some (If (e1', e2, e3))
      | None -> (
          match e1 with
          | Bool true -> Some e2
          | Bool false -> Some e3
          | _ -> failwith "Invalid guard expression"))
```

---

# Substitution Model Evaluation

## Small-Step Semantics

### Let

```typst +render +width:80%
$
"LET-V" & (e_1 -> e'_1) /
          ("let" x=e_1 "in" e_2 -> "let" x=e'_1 "in" e_2) 
$
```

<!-- pause -->

what is the other rule?

---

# Substitution Model Evaluation

## Small-Step Semantics

### Let

```typst +render +width:75%
$
"LET-B" & (e_1 cancel(->)) /
          ("let" x=e_1 "in" e_2 -> [e_1\/x]e_2)
$
```

this is the only rule that uses substitution!

---

# Substitution Model Evaluation

## Small-Step Semantics

### Let

```ocaml
let rec step : expr -> expr option = function
  | Let (x, e1, e2) -> (
      match step e1 with
      | Some e1' -> Some (Let (x, e1', e2))
      | None -> Some (subst e1 x e2))
```

---

# Substitution Model Evaluation

## Small-Step Semantics

### Variables

In the substitution model, variables should be replaced with values (via the
LET-B rule) before we get to them.

<!-- pause -->

```typst +render +width:25%
$
"VAR" () / (x cancel(->))
$
```

<!-- pause -->

```ocaml
let rec step : expr -> expr option = function
  | Var _ -> None
```

---

# Substitution Model Evaluation

## Small-Step Semantics

```ocaml
let rec step : expr -> expr option = function
  | Int _ | Bool _ | Var _ -> None
  | Binop (bop, e1, e2) -> (match step e1 with
      | Some e1' -> Some (Binop (bop, e1', e2))
      | None -> (match step e2 with
          | Some e2' -> Some (Binop (bop, e1, e2'))
          | None -> (match (bop, e1, e2) with
              | Add, Int a, Int b -> Some (Int (a + b))
              | Mult, Int a, Int b -> Some (Int (a * b))
              | Leq, Int a, Int b -> Some (Bool (a <= b))))
  | If (b, e1, e2) -> (match step b with
      | Some b' -> Some (If (b', e1, e2))
      | None -> (match b with
          | Bool true -> Some e1
          | Bool false -> Some e2))
  | Let (x, e1, e2) -> (match step e1 with
      | Some e1' -> Some (Let (x, e1', e2))
      | None -> Some (subst e1 x e2))
```

---

# Substitution Model Evaluation

## Small-Step Semantics

```typst +render +width:25%
$e ~> v$
```

```ocaml
let rec multistep (e : expr) : expr =
  match step e with
  | None -> e
  | Some e' -> multistep e'
```

---

# Substitution Model Evaluation

## Big-Step Semantics

<!-- pause -->

### Values

Unlike with small-step semantics, values just evaluate to themselves.

```typst +render +width:70%
$
#let bstep = sym.arrow.b.double

"INT" & (i : "int")/(i bstep i) wide

"BOOL" (b : "bool")/(b bstep b) wide
$
```

<!-- pause -->

```ocaml
let rec eval e = match e with
  | Int _  -> e
  | Bool _ -> e
```

---

# Substitution Model Evaluation

## Big-Step Semantics

### Binary Operations

```typst +render +width:70%
$
#let bstep = sym.arrow.b.double
#let bop = sym.plus.circle

"BOP" & (e_1 bstep v_1 quad e_2 bstep v_2
         quad r=v_1 bop v_2) /
        (e_1 bop e_2 bstep r) 
$
```

<!-- pause -->

<!-- incremental_lists: true -->

With big-step semantics, we boil expressions down to values in a single step!

- concise and easier to understand

- hides intermediate steps (e.g., order of execution isn't clear)

- hard to explain *divergence* (e.g., non-terminating programs)

---

# Substitution Model Evaluation

## Big-Step Semantics

### Binary Operations

```ocaml
let rec eval e = match e with
  | Binop (bop, e1, e2) -> (
      match (bop, eval e1, eval e2) with
      | Add,  Int a, Int b -> Int (a + b)
      | Mult, Int a, Int b -> Int (a * b)
      | Leq,  Int a, Int b -> Bool (a <= b)
      | _ -> failwith "Invalid operands")
```

---

# Substitution Model Evaluation

## Big-Step Semantics

### If

Can you write the big-step rules for `if-then-else` expressions?

<!-- pause -->

```typst +render +width:60%
$
#let bstep = sym.arrow.b.double
#let bop = sym.plus.circle

"IF-T" & (e_1 bstep "true" quad e_2 bstep v_2) /
         ("if" e_1 "then" e_2 "else" e_3 bstep v_2) \ \

"IF-F" & (e_1 bstep "false" quad e_3 bstep v_3) /
         ("if" e_1 "then" e_2 "else" e_3 bstep v_3) 
$
```

Remember, big-step reduces expressions to *values* in a single step.

---

# Substitution Model Evaluation

## Big-Step Semantics

### If

```ocaml
let rec eval e = match e with
  | If (e1, e2, e3) -> (
      match eval e1 with
      | Bool true  -> eval e2
      | Bool false -> eval e3
      | _ -> failwith "Invalid guard expression")
```

---

# Substitution Model Evaluation

## Big-Step Semantics

### Let

Try writing the big-step rule for `let` expressions.

<!-- pause -->

```typst +render +width:60%
$
#let bstep = sym.arrow.b.double
#let bop = sym.plus.circle

"LET" & (e_1 bstep v_1 quad [v_1\/x]e_2 bstep v_2) /
        ("let" x=e_1 "in" e_2 bstep v_2)
$
```

<!-- pause -->

```ocaml
let rec eval e = match e with
  | Let (x, e1, e2) -> eval (subst (eval e1) x e2)
```

---

# Substitution Model Evaluation

## Big-Step Semantics

### Variables

Just as with small-step semantics, variables cannot be evaluated on their own
when using the substitution model.

```typst +render +width:25%
$
"VAR" () / (x cancel(arrow.b.double))
$
```

---

# Substitution Model Evaluation

## Big-Step Semantics

```ocaml
let rec eval (e : expr) : expr =
  match e with
  | Int _ | Bool _ -> e
  | Var _ -> failwith "Unbound variable"
  | Binop (bop, e1, e2) -> (
      match (bop, eval e1, eval e2) with
      | Add, Int a, Int b -> Int (a + b)
      | Mult, Int a, Int b -> Int (a * b)
      | Leq, Int a, Int b -> Bool (a <= b)
      | _ -> failwith "Invalid operands")
  | If (e1, e2, e3) -> (
      match eval e1 with
      | Bool true -> eval e2
      | Bool false -> eval e3
      | _ -> failwith "Invalid guard expression")
  | Let (x, e1, e2) -> eval (subst (eval e1) x e2)
```
