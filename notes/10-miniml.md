# MiniML

## Agenda

- MiniML
- Evaluating Functions & Application
  - Lexical vs. Dynamic Scope
- Functions of 2+ Arguments
  - Desugaring

## MiniML

SimPL provided a good set of interpreter training wheels, but it lacks an essential feature: *functions*.

Let's add function definition and application to our language:

```bnf {5-6}
<expr>  ::= <int> | <bool> | <var>
          | <expr> <bop> <expr>
          | if <expr> then <expr> else <expr>
          | let <var> = <expr> in <expr>
          | fun <var> -> <expr>
          | <expr> <expr>
```

## MiniML AST

We update our ADT with two new values:

```ocaml {8-9}
type expr =
  | Int of int
  | Bool of bool
  | Var of string
  | Binop of bop * expr * expr
  | If of expr * expr * expr
  | Let of string * expr * expr
  | Fun of string * expr
  | App of expr * expr
```

## Parsing MiniML

And update the front-end, so that:

```ocaml
# Eval.parse "fun x -> x+1";;
- : expr = Fun ("x", Binop (Add, Var "x", Int 1))

# Eval.parse "f g";;
- : expr = App (Var "f", Var "g")

# Eval.parse "(fun x -> x+1) 439";;
- : expr = App (Fun ("x", Binop (Add, Var "x", Int 1)),
                Int 439)
```

## Big-Step Environment-Model Evaluation

### `fun`

What happens when we encounter a `fun`? What does it evaluate to?

Naive approach: a `fun` is just a value that evaluates to itself.

```typst +render +width:60%
#let bstep = sym.arrow.b.double
#let state(e,s) = { $angle.l #e,#s angle.r$ }
#let closure(e,s) = { $shell.l #e, #s shell.r$ }

$
"FUN" & ()
         /
        (state("fun" x "->" e,sigma) bstep ("fun" x "->" e))
$
```

```ocaml {6}
let rec eval (e : expr) (env: env) : value =
  match e with
  | Int i  -> VInt i
  | Bool b -> VBool b
  ...
  | Fun (x, body) -> VFun (x, body)
```

### Application (`e1 e2`)

Application involves evaluating a function's body with its variable bound to an argument value.

```typst +render +width:100%
#let bstep = sym.arrow.b.double
#let state(e,s) = { $angle.l #e,#s angle.r$ }
#let mapto = sym.arrow.r.bar

$
"APP" & (state(e_1,sigma) bstep ("fun" x "->" e'_1)
         quad state(e_2,sigma) bstep v_2
         quad state(e'_1, sigma[x mapto v_2]) bstep v
        ) /
        (state(e_1 e_2,sigma) bstep v)
$
```

```ocaml {3-7}
let rec eval (e : expr) (env: env) : value =
  match e with
  | App (e1, e2) -> (
      match eval e1 env with
      | VFun (x, e1') -> (
          let v2 = eval e2 env in
          eval e1' ((x,v2) :: env))
```

### Sanity Check

How does our implementation behave in the following example?

```ocaml
let y=5 in
let f=fun x->x+y in
let y=6 in
f 10
```

```ocaml {1}
let y=5 in            env=[]
let f=fun x->x+y in
let y=6 in
f 10
```

```ocaml {2}
let y=5 in
let f=fun x->x+y in   env=[(y,5)]
let y=6 in
f 10
```

```ocaml {3}
let y=5 in
let f=fun x->x+y in
let y=6 in            env=[(f,fun x->x+y); (y,5)]
f 10
```

```ocaml {4}
let y=5 in
let f=fun x->x+y in
let y=6 in
f 10                  env=[(y,6); (f,fun x->x+y); (y,5)]
```

We evaluate `(x+y)` with env=`[(x,10); (y,6); ...]`

= 16

### Dynamic Scoping

Our current set of rules apply a function by using the *dynamic environment* to look up free variables in its body. We call this *dynamic scoping*.

```typst +render +width:100%
#let bstep = sym.arrow.b.double
#let state(e,s) = { $angle.l #e,#s angle.r$ }
#let mapto = sym.arrow.r.bar

$
"FUN" & ()
         /
        (state("fun" x "->" e,sigma) bstep ("fun" x "->" e)) \ \

"APP" & (state(e_1,sigma) bstep ("fun" x "->" e'_1)
         quad state(e_2,sigma) bstep v_2
         quad state(e'_1, text(fill:#red,sigma)[x mapto v_2]) bstep v
        ) /
        (state(e_1 e_2,text(fill:#red,sigma)) bstep v)
$
```

## What would OCaml do?

Predict the results:

```ocaml
let y=5 in
let f=(fun x->x+y) in
let y=6 in
f 10
```

```ocaml
let f=(let y=5 in (fun x->x+y)) in
let y=6 in
f 10
```

```ocaml
let f=(fun x->x+y) in
let y=5 in
f 10
```

What do we get when we evaluate a `fun` in some environment?

```ocaml
let y=5 in fun x->x+y
```

We get back a ***closure***.

- A combination of the function's definition and *the environment in which it was defined* (aka its *lexical environment*).

## Big-Step Environment-Model Evaluation with Closures

### fun => closure

We'll update our rule so that evaluating a `fun` expression results in a closure.

```typst +render +width:75%
#let bstep = sym.arrow.b.double
#let state(e,s) = { $angle.l #e,#s angle.r$ }
#let closure(e,s) = { $shell.l #e, #s shell.r$ }

$
"CLOSURE" & ()
         /
        (state("fun" x "->" e,sigma)
        bstep
        text(fill:#yellow,[|"fun" x "->" e, sigma|]))
$
```

```ocaml {3}
type value = VInt of int
           | VBool of bool
           | Closure of (string * expr * env)
```

```ocaml {6}
let rec eval (e : expr) (env: env) : value =
  match e with
  | Int i  -> VInt i
  | Bool b -> VBool b
  ...
  | Fun (x, body) -> Closure (x, body, env)
```

### Application (`e1 e2`)

We'll also update application to expect a closure from evaluating `e1`, and to evaluate its body in the saved environment:

```typst +render +width:100%
#let bstep = sym.arrow.b.double
#let state(e,s) = { $angle.l #e,#s angle.r$ }
#let mapto = sym.arrow.r.bar

$
"APP" & (state(e_1,sigma)
           bstep text(fill:#yellow,[| "fun" x "->" e'_1, sigma' |])
         quad state(e_2,sigma) bstep v_2
         quad state(e'_1, text(fill:#yellow,sigma')[x mapto v_2]) bstep v
        ) /
        (state(e_1 e_2,sigma) bstep v)
$
```

```ocaml {5,7}
let rec eval (e : expr) (env: env) : value =
  match e with
  | App (e1, e2) -> (
      match eval e1 env with
      | Closure (x, e1', env') -> (
          let v2 = eval e2 env in
          eval e1' ((x, v2) :: env'))
```

### Lexical Scoping

Our updated set of rules use the *lexical environment* captured by a closure to look up free variables in a function's body during application.

```typst +render +width:100%
#let bstep = sym.arrow.b.double
#let state(e,s) = { $angle.l #e,#s angle.r$ }
#let closure(e,s) = { $shell.l #e, #s shell.r$ }
#let mapto = sym.arrow.r.bar

$
"CLOSURE" & ()
         /
        (state("fun" x "->" e,sigma)
        bstep
        [|"fun" x "->" e, sigma|]) \ \

"APP" & (state(e_1,sigma) bstep [| "fun" x "->" e'_1, text(fill:#red,sigma') |]
         quad state(e_2,sigma) bstep v_2
         quad state(e'_1, text(fill:#red,sigma')[x mapto v_2]) bstep v
        ) /
        (state(e_1 e_2,sigma) bstep v)
$
```

### Dynamic vs. Lexical Scoping

Our provided implementation allows us to play with both scoping strategies:

```ocaml {1-2,10-14}
type scope_rule = Lexical | Dynamic
let scope = Lexical

let rec eval (e : expr) (env: env) : value =
  match e with
  | App (e1, e2) -> (
      match eval e1 env with
      | Closure (x, e1', lexenv) -> (
          let v2 = eval e2 env in
          let base_env = match scope with
            | Lexical -> lexenv
            | Dynamic -> env in
          eval e1' ((x,v2) :: base_env))
```

- Lexical scoping is ...

  - more predictable and modular: a function's behavior is based on its static definition, not its calling context

  - less flexible: we cannot easily override bindings used by the function (or have it use the caller's bindings)

  - matches most modern implementations

- Dynamic scoping is ...

  - unpredictable and hard to debug: functions may behave differently depending on where they're called from

  - flexible and possibly more concise: functions can automatically access variables defined by their callers (useful for dynamic configuration)

  - incompatible with modern compiler optimizations / static analysis

## Functions of 2+ Args

What if we wanted to support functions of more than 1 argument?

```bnf {6,8}
<expr>  ::= <int> | <bool> | <var>
          | <expr> <bop> <expr>
          | if <expr> then <expr> else <expr>
          | let <var> = <expr> in <expr>
          | <expr> <expr>
          | fun <args> -> <expr>

<args> ::= <var> | <var> <args>
```

### Approach 1: Update Front-End + Evaluator

We start by updating the AST:

```ocaml {8}
type expr =
  | Int of int
  | Bool of bool
  | Var of string
  | Binop of bop * expr * expr
  | If of expr * expr * expr
  | Let of string * expr * expr
  | Fun of string list * expr
  | App of expr * expr
```

Then, after updating the front-end to recognize the new syntax and return appropriate ADTs, update necessary value types:

```ocaml {3}
type value = VInt of int
           | VBool of bool
           | Closure of (string list * expr * env)
```

and the evaluator:

```ocaml {6-7}
let rec eval (e : expr) (env: env) : value =
  match e with
  | Fun (xs, body) -> Closure (xs, body, env)
  | App (e1, e2) -> (
      match eval e1 env with
      | Closure (xs, e1', env') ->
          (* evaluate the closure (how?) *)
```

But we're not really introducing any new semantics, so why are we updating the `eval` function?!

We should recognize that:

```ocaml
(fun x y z ... -> body)
```

is, thanks to currying, *syntactic sugar* for:

```ocaml
(fun x -> fun y -> fun z ... -> body)
```

### Approach 2: Desugaring

A simpler approach is to only modify the grammar and parser, and when we encounter the `fun x y z ... -> body` syntax, to *desugar* it into the explicitly curried form.

```ocamlex
expr:
  | FUN xs=args ARROW e=expr  { curry xs e }

args:
  | x=ID                      { [x]        }
  | x=ID xs=args              { x :: xs    }
```

```ocaml
let curry (args: string list) (body: expr) : expr =
  List.fold_right (fun arg body -> Fun (arg, body))
                  args body
```

Now the parser will only produce ASTs of the form `fun x -> fun y -> ...`

```ocaml
# Eval.parse "fun x y -> x+y";;
- : expr = Fun ("x", Fun ("y",
             Binop (Add, Var "x", Var "y")))

# Eval.parse "fun x -> fun y -> x+y";;
- : expr = Fun ("x", Fun ("y",
             Binop (Add, Var "x", Var "y")))
```

We don't need to touch the AST or the Evaluator!

## On Desugaring

Benefits of the desugaring approach:

- Less work!

- Pretty syntax makes users happy.

- Smaller "core" syntax for the language is easier to reason about.

- Leaner evaluator is easier to test.
