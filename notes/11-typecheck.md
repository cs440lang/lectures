# Type Checking

## Agenda

- Typing Contexts and Static Semantics
  - Typing Notation
  - Type Safety
  - Preservation and Progress
- A Type Checker for MiniML
- Limitations and Shortcomings

## Dynamic Semantics

Operational semantics specify *dynamic semantics*: they describe how evaluation proceeds step by step at *runtime* to produce a final result.

But situations arose where evaluation would get "stuck"; i.e., no evaluation rule could be applied. E.g.,

```ocaml {4,7,10,13}
let rec eval (e : expr) (env: env) : value = match e with
  | Var v -> (...
      | Some y -> y
      | _ -> raise (RuntimeError "Unbound variable"))
  | Binop (bop, e1, e2) -> (...
      | Add, VInt a, VInt b -> ... | Mult, VInt a, VInt b -> ...
      | _ -> raise (RuntimeError "Invalid bop operands"))
  | If (e1, e2, e3) -> (...
      | VBool true -> ... | VBool false -> ...
      | _ -> raise (RuntimeError "Invalid guard"))
  | App (e1, e2) -> (...
      | Closure (x, body, defenv) -> ...
      | _ -> raise (RuntimeError "Invalid application"))
```

## Getting Stuck

In many cases, evaluation gets stuck because of type-related issues. E.g.,

- `1 + true`

- `let f=5 in f 10`

- `(fun x -> x + 1) (fun y -> y)`

Wouldn't it be cool if we could prevent these issues from ever arising?

## Type Systems and Static Semantics

A *type system* describes the *static semantics* of a program via *typing rules*.

*Type checking* is the process of validating those rules at *compile-time* so we can prevent the evaluation of programs that are doomed to fail.

Just as evaluation uses a dynamic environment (`σ`) that maps variables to values, type checking uses a static environment (`Γ`) -- aka typing context -- that maps variables to *types*.

## Typing Notation and Judgments

Static semantics focuses on types, contexts, and related assertions/judgments.

```typst +render +width:70%
#let mapto = sym.arrow.r.bar
#let tstile = sym.tack.r

#grid(
  columns: 2,
  gutter: 1em,
  align: (right, left),

  [$Gamma tstile e : tau$], [Under $Gamma$, expression $e$ has type $tau$],

  [$tstile e : tau$], [$e$ has type $tau$ in the empty context],

  [$Gamma(x)$], [Look up the type assigned to var $x$ in $Gamma$],

  [$Gamma(x) = tau$], [In $Gamma$, variable $x$ has type $tau$],

  [$Gamma[x mapto tau]$], [Extend $Gamma$ by assigning var $x$ the type $tau$],
)
```

A type-checker tries to prove the judgment `⊢ e : τ` for program `e`. If it succeeds, the program is *well-typed*, else it is *ill-typed*.

## Type Systems as Proof Systems

Type systems provide a mathematical framework for proving that well-typed programs will not get stuck when run. This guarantee is called *type-safety*.

Formally, we relate static and dynamic semantics with the following properties:

- *Preservation*: a well-typed expression's type will not change if stepped.

- *Progress*: a well-typed expression is either a value or can be stepped.

```typst +render +width:80%
#let tstile = sym.tack.r

$
"PRESERVATION" & (tstile e : tau quad e -> e') / (tstile e' : tau) \
\

"PROGRESS" & (tstile e : tau)
             / ((e -> e') "or" (e "is a value"))
$
```

## Caveats and Examples

Type safety guarantees that *well-typed programs won't get stuck*.

But it doesn't say that:

- Every non-stuck program is well-typed.

- Every well-typed programs will terminate.

E.g.,

- `5 + true` is ill-typed; it isn't a value and is stuck

- `(false 42)` is ill-typed; it isn't a value and is stuck

- `if 1 <= 2 then 5 else false` is ill-typed but can be stepped

## Type Checking

How do we implement a type-checker?

Approach 1: Explicit (Annotation-Driven) Type Checking

- Types are *declared explicitly* by the programmer

- Typing rules verify consistency between annotations and values

- Type checking = *verification*: top-down flow (from annotations)

  - i.e., "Given declared types, does this program obey them?"

- Types are usually *monomorphic* (e.g., `int -> int`)

How do we implement a type-checker?

Approach 2: Implicit (Inferred) Type Checking

- Types are *inferred* from expressions and operations

- Introduces unknowns (type variables), generates constraints, and solves them using *unification*

- Inference = *discovery*: bottom-up flow (from subexpressions)

  - i.e., "What types would make this program well-typed?"

- Supports *polymorphism* (e.g., `∀ a. a -> a`)

## Explicit Type Checking

We define a new ADT to represent the three concrete types in MiniML:

```ocaml
type typ = TInt | TBool | TFun of (typ * typ)
```

We represent Γ, the typing context, as an associative list:

```ocaml
type tenv = (string * typ) list
```

Our goal is to implement `typeof`:

```ocaml
val typeof : expr -> tenv -> typ
```

If `typeof` derives a `typ` for `expr` using `tenv`, `expr` is well-typed.

## Type Annotations

Functions are modified to include explicit *type annotations* for arguments:

```ocaml {1,6}
type expr =
  | Int of int
  | Bool of bool
  ...
  | App of expr * expr
  | Fun of string * typ * expr
```

E.g.,

```ocaml
fun x:int -> x + 1

let inc = fun x:int -> x + 1 in inc 41
```

## Static Semantics Rules

### Values

Integer and boolean literals have intrinsic types.

```typst +render +width:50%
#let bop = sym.plus.circle
#let tstile = sym.tack.r

$
"INT"    & () / (Gamma tstile i in ZZ : "int") \

"BOOL-T" & () / (Gamma tstile "true" : "bool") \

"BOOL-F" & () / (Gamma tstile "false" : "bool")
$
```

```ocaml
let rec typeof (e : expr) (tenv : tenv) = match e with
  | Int _ -> TInt
  | Bool _ -> TBool
```

### Variables

A variable's type must be declared in the current context:

```typst +render +width:40%
#let bop = sym.plus.circle
#let tstile = sym.tack.r
#let mapto = sym.arrow.r.bar

$
"VAR"    & (Gamma(x) = tau) / (Gamma tstile x : tau) \
$
```

```ocaml
| Var x -> (
    match List.assoc_opt x tenv with
    | Some t -> t
    | None -> raise (TypeError (Printf.sprintf "%s undeclared" x)))
```

## Type Checking in the Interpreter

We define a new type of exception:

```ocaml
exception TypeError of string
```

Our REPL type-checks before evaluation. `TypeError`s will prevent ill-typed programs from being evaluated.

```ocaml {3,8-9}
try
  let expr = parse line in
  let typ = typeof expr [] in
  let value = eval expr [] in
  Printf.printf "- : %s = %s\n"
    (string_of_type typ) (string_of_val value);
with
| TypeError msg ->
    Printf.printf "Type Error: %s\n" msg;
```

### Binary Operators

```typst +render +width:80%
#let bop = sym.plus.circle
#let tstile = sym.tack.r

$
"BOP-I"  & (bop in {+,*}
            quad Gamma tstile e_1 : "int"
            quad Gamma tstile e_2 : "int")
           / (Gamma tstile e_1 bop e_2 : "int") \


"BOP-B"  & (bop in {<=}
            quad Gamma tstile e_1 : "int"
            quad Gamma tstile e_2 : "int")
           / (Gamma tstile e_1 bop e_2 : "bool")
$
```

```ocaml
| Binop (bop, e1, e2) -> (
    let t1 = typeof e1 tenv in
    let t2 = typeof e2 tenv in
    match (bop, t1, t2) with
    | Add, TInt, TInt -> TInt
    | Mult, TInt, TInt -> TInt
    | Leq, TInt, TInt -> TBool
    | _ -> raise (TypeError "Invalid bop operands"))
```

### `if-then-else`

The guard must be a boolean and both branches must agree on the result type.

```typst +render +width:80%
#let bop = sym.plus.circle
#let tstile = sym.tack.r

$
"IF"  (Gamma tstile e_1 : "bool"
       quad Gamma tstile e_2 : tau
       quad Gamma tstile e_3 : tau)
      / (Gamma tstile "if" e_1 "then" e_2 "else" e_3 : tau)
$
```

```ocaml
| If (e1, e2, e3) ->
    let t1 = typeof e1 tenv in
    if t1 <> TBool then raise (TypeError "Invalid guard")
    else
      let t2 = typeof e2 tenv in
      let t3 = typeof e3 tenv in
      if t2 = t3 then t3
      else raise (TypeError "Branches don't match")
```

Why do the branches need to agree? Is this program stuck?

`if 1 <= 2 then 5 else false`

How about this?

`if (if 1 <= 2 then 5 else false) then 10 else 20`

Type checkers ignore dynamic semantics. They must be *conservative*: every subexpression -- even those never evaluated -- must be well-typed for the program to be well-typed.

### `let`

`let` bindings need not be explicitly annotated. We can perform *local inference* to compute their types and extend the environment.

```typst +render +width:80%
#let bop = sym.plus.circle
#let tstile = sym.tack.r
#let mapto = sym.arrow.r.bar


$
"LET" (Gamma tstile e_1 : tau
       quad Gamma[x mapto tau] tstile e_2 : tau')
      / (Gamma tstile "let" x=e_1 "in" e_2 : tau')
$
```

```ocaml
| Let (x, e1, e2) ->
    let t = typeof e1 tenv in
    typeof e2 ((x, t) :: tenv)
```

### `fun`

Functions need type annotations because we can't always locally infer them.

```typst +render +width:80%
#let bop = sym.plus.circle
#let tstile = sym.tack.r
#let mapto = sym.arrow.r.bar

$
"FUN" (Gamma[x mapto tau] tstile e : tau')
      / (Gamma tstile "fun" x : tau "->" e :  tau -> tau')
$
```

```ocaml
| Fun (x, t, e) ->
    let t' = typeof e ((x, t) :: tenv) in
    TFun (t, t')
```

### Application

Application requires the function expression to have a type whose domain matches the argument's type.

```typst +render +width:80%
#let bop = sym.plus.circle
#let tstile = sym.tack.r

$
"APP" (Gamma tstile e_1 : tau -> tau'
       quad Gamma tstile e_2 : tau)
      / (Gamma tstile e_1 e_2 : tau')
$
```

```ocaml
| App (e1, e2) -> (
    let t1 = typeof e1 tenv in
    let t2 = typeof e2 tenv in
    match t1 with
    | TFun (t, t') ->
        if t = t2 then t'
        else raise (TypeError "Function/Arg type mismatch")
    | _ -> raise (TypeError "Non-function type being applied"))
```

## Typing Proofs

Using the typing rules, how can we prove the following programs are well-typed?

- `2 <= (3 + 4)`

- `let x=5 in if x <= 10 then 20 else x`

- `let f=fun x:int -> x * 10 in f (1 + 2)`

## Proof Trees

```typst +render +width:100%
#let bop = sym.plus.circle
#let tstile = sym.tack.r
#let mapto = sym.arrow.r.bar
#let bstep = sym.arrow.b.double
#let state(e, s) = { $angle.l #e,#s angle.r$ }

#let nonumeq = math.equation.with(block: true, numbering: none)
#let dm(x) = box[#nonumeq[#x]]
#let dfrac(x, y) = math.frac(dm(x), dm(y))

#show math.equation.where(block: true): set par(leading: 2em)

$
  "BOP-B" dfrac(
    bop in {*,+} quad
    "INT" dfrac(, tstile 2 : "int") wide
    "BOP-I" dfrac(bop in {*,+}
                  quad "INT" dfrac(, tstile 3 : "int")
                  quad "INT" dfrac(, tstile 4 : "int"),
                  tstile 3+4 : "int"),
    tstile 2 <= (3+4) : "bool"
  )
$
```

## Demo

```ocaml
dune utop

# open L09_typecheck;;
# Eval.repl ();;
```

## Limitations and Shortcomings

Explicit type checking is simple, predictable, and fast, but ...

- programmers must write verbose type annotations, even when obvious

  - increasingly annoying with complex features (e.g., lists, HOFs)

- polymorphic types require explicit quantification or type args on use

  - e.g., specifying type parameters with Java/C#/TypeScript generics

```Java
<T> T id(T x) { return x; }

id<Integer>(3)
```

- no guarantee that the *most general type* is used -- only the one declared

  - as can be algorithmically derived via *type inference* (coming next!)
