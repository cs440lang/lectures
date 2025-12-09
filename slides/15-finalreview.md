---
title: "Final Exam Review"
sub_title: "CS 440: Programming Languages"
author: "Michael Lee"
---

# Agenda

- Final exam coverage
- Exam breakdown
  - Sample problems

---

# Final Exam Coverage

- High-level interpreter & compiler concepts
- Operational semantics
- Evaluator implementation
- Explicit type checking
- Type inference

---

# Final Exam Coverage

## High-Level Interpreter & Compiler Concepts

- Lexing
- Parsing
- Parser generators and Grammars (Backus-Naur Form - BNF)
- Abstract Syntax Tree / Intermediate Representation
- Evaluation
- Compilation / Transpilation

---

# Final Exam Coverage

## Operational Semantics

- Rules of inference
- Small-step semantics
- Big-step semantics

---

# Final Exam Coverage

## Evaluator Implementation

- Operations semantics rules -> `eval`
- Substitution-model evaluation
- Environment-model evaluation
  - Dynamic environments
- Lexical vs. Dynamic scope
  - Closures
- Desugaring

---

# Final Exam Coverage

## Explicit type checking

- Explicit vs. Implicit type checking
- Typing rules
- Type safety
  - Progress and Preservation
- Static (Type) environments

---

# Final Exam Coverage

## Type inference

- Type inference rules
- Constraint generation
- Unification
- Monomorphic type inference
- Polymorphic type inference
  - Type schemes & Instantiation/Generalization

---

# Exam Breakdown

- 10-15 Multiple choice questions (~20% weight)
- 4-6 Short answer conceptual questions (~20% weight)
- 4 Derivation/Proof questions (~60% weight)

---

# Exam Breakdown

## Derivation/Proof Questions

1. *Parsing*: MiniML Code -> AST
2. *Evaluator implementation*: AST + Semantic rule(s) -> `eval`
3. *Explicit type checking*: Typing proof (proof tree derivation)
4. *Type inference*: Type derivation (constraint generation + unification)

---

## Sample Derivation/Proof Questions

### 1. Parsing

Translate the following MiniML expressions into their AST representations:

- `let x=5 in 2*x`

- `let f=fun x -> 2*x in f 10`

- `(fun x -> fun y -> x) 1 2`

<!-- pause -->

Solutions:

- `Let ("x", Int 5, Binop (Mult, Int 2, Var "x"))`

- `Let ("f", Fun ("x", Binop (Mult, Int 2, Var "x")), App (Var "f", Int 10))`

- `App (App (Fun ("x", Fun ("y", Var "x")), Int 1), Int 2)`

---

## Sample Derivation/Proof Questions

### 2. Evaluator implementation

Implement the new MiniML construct `not e`, with the AST form:

```ocaml
type expr = Not of expr
```

`not` evaluates to `true` when its argument is either `false` or `0`, and
evaluates to `false` otherwise. Here are the big-step semantic rules for `not`:

```typst +render +width:60%
#let bstep = sym.arrow.b.double
#let bop = sym.plus.o
#let state(e,s) = { $chevron.l #e,#s chevron.r$ }

$
"NOT_T" & (state(e,sigma) bstep v quad v in { "false", 0 }) /
        (state("not" e,sigma) bstep "true")\ 

        
"NOT_F" & (state(e,sigma) bstep v quad v in.not { "false", 0 }) /
        (state("not" e,sigma) bstep "false") 
$
```

---

## Sample Derivation/Proof Questions

### 2. Evaluator implementation (Solution)

```ocaml {3-7}
let rec eval (e : expr) (env : env) : value =
  match e with
  | Not e -> (
      match eval e env with
      | VInt 0 -> VBool true
      | VBool false -> VBool true
      | _ -> VBool false)
```

<!-- pause -->

```ocaml
# eval (Not (Bool false)) [];; (* `not false` *)
- : value = VBool true

# eval (Not (Binop (Mult, Int 10, Int 0))) [];; (* `not 0` *)
- : value = VBool true

# eval (Not (Fun ("x", Var "x"))) [];; (* `not (fun x -> x)` *)
- : value = VBool false
```

---

## Sample Derivation/Proof Questions

### 3. Explicit type checking

Construct a typing proof (proof tree) for each of the following expressions.
Indicate whether the expression is well- or ill-typed.

- `let x = 42 in if x <= 0 then 10 else x`
- `let f = fun x:int -> x*2 in f 7`

---

## Sample Derivation/Proof Questions

### 3. Explicit type checking (Solution)

`let x = 42 in if x <= 0 then 10 else x`

```
{} |- let x = 42 in if x <= 0 then 10 else x : int
  {} |- 42 : int
  { x : int } |- if x <= 0 then 10 else x : int
    { x : int } |- x <= 0 : bool
      { x : int } |- x : int
      { x : int } |- 0 : int
    { x : int } |- 10 : int
    { x : int } |- x : int
```

Well-typed

---

## Sample Derivation/Proof Questions

### 3. Explicit type checking (Solution)

let x = 42 in if x <= 0 then `true` else x

```
{} |- let x = 42 in if x <= 0 then true else x : ?
  {} |- 42 : int
  { x : int } |- if x <= 0 then true else x : ?
    { x : int } |- x <= 0 : bool
      { x : int } |- x : int
      { x : int } |- 0 : int
    { x : int } |- true : bool <-┐
    { x : int } |- x : int <-----┴-- mismatch
```

Ill-typed

---

## Sample Derivation/Proof Questions

### 3. Explicit type checking (Solution)

`let f = fun x:int -> x*2 in f 7`

```
{} |- let f = fun x:int -> x*2 in f 7: int
  {} |- fun x:int -> x*2 : int -> int
    { x : int } |- x*2 : int
      { x : int } |- x : int
      { x : int } |- 2 : int
  { f : int -> int } |- f 7 : int
    { f : int -> int } |- f : int -> int
    { f : int -> int } |- 7 : int
```

Well-typed

---

## Sample Derivation/Proof Questions

### 3. Explicit type checking (Solution)

let f = fun x:int -> x*2 in f `true`

```
{} |- let f = fun x:int -> x*2 in f true: ?
  {} |- fun x:int -> x*2 : int -> int
    { x : int } |- x*2 : int
      { x : int } |- x : int
      { x : int } |- 2 : int
  { f : int -> int } |- f true : int
    { f : int -> int } |- f : int -> int <--┐
    { f : int -> int } |- true : bool <-----┴-- mismatch
```

Ill-typed

---

## Sample Derivation/Proof Questions

### 4. Type inference

Infer the type of the following expressions. Show the *derivation tree*,
including all type variables, generated constraints, and the raw type.

Next, show the steps for *unifying* the constraints and computing the MGU, and
clearly indicate either the *principal type* or unification error.

- `fun x -> x + 1` / `fun x -> x + true`
- `fun x -> if x then 0 else x + 1`
- `(fun x -> x + 1) 42`

---

## Sample Derivation/Proof Questions

### 4. Type inference (Solution)

`fun x -> x + 1`

```
{} |- fun x -> x + 1 : 'a -> int -| { 'a = int, int = int }
  { x : 'a } |- x + 1 : int -| { 'a = int, int = int }
    { x : 'a } |- x : 'a -| {}
    { x : 'a } |- 1 : int -| {}

C = { 'a = int, int = int }

U('a = int) = 'a |-> int
U(int = int)

S = { 'a |-> int }

fun x -> x + 1 : int -> int
```

---

## Sample Derivation/Proof Questions

### 4. Type inference (Solution)

`fun x -> x + true`

```
{} |- fun x -> x + true : 'a -> int -| { 'a = int, bool = int }
  { x : 'a } |- x + true : int -| { 'a = int, bool = int }
    { x : 'a } |- x : 'a -| {}
    { x : 'a } |- true : bool -| {}

C = { 'a = int, bool = int }

U('a = int) = 'a |-> int
U(bool = int) = Unification failure: type mismatch
```

---

## Sample Derivation/Proof Questions

### 4. Type inference (Solution)

`fun x -> if x then 0 else x + 1`

```
{} |- fun x -> if x then 0 else x + 1 : 'a -> 'b
      -| { 'a = bool, 'b = int, 'b = int, 'a = int, int = int }
  { x : 'a } |- if x then 0 else x + 1 : 'b
      -| { 'a = bool, 'b = int, 'b = int, 'a = int, int = int }
    { x : 'a } |- x : 'a -| {}
    { x : 'a } |- 0 : int -| {}
    { x : 'a } |- x + 1 : int -| { 'a = int, int = int }
      { x : 'a } |- x : 'a -| {}
      { x : 'a } |- 1 : int -| {}

C = { 'a = bool, 'b = int, 'b = int, 'a = int, int = int }

U('a = bool) = 'a |-> bool
U('b = int) = 'b |-> int
U(int = int)
U(bool = int) = Unification failure: type mismatch
```

---

## Sample Derivation/Proof Questions

### 4. Type inference (Solution)

`(fun x -> x + 1) 42`

```
{} |- (fun x -> x + 1) 42 : 'a -| { 'b -> int = int -> 'a,
                                    'b = int, int = int }
  {} |- fun x -> x + 1 : 'b -> int -| { 'b = int, int = int }
    { x : 'b } |- x + 1 : int -| { 'b = int, int = int }
      { x : 'b } |- x : 'b -| {}
      { x : 'b } |- 1 : int -| {}
  {} |- 42 : int -| {}

C = { 'b -> int = int -> 'a, 'b = int, int = int }

U('b -> int = int -> 'a) = U('b = int); U(int = 'a)
U('b = int) = 'b |-> int
U(int = 'a) = 'a |-> int
U(int = int)
U(int = int)

S = { 'b |-> int, 'a |-> int }

(fun x -> x + 1) 42 : int
```
