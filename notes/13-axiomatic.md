# Axiomatic Semantics

## Agenda

- Why another semantics?
- Axiomatic Semantics and Hoare Triples
- Axiomatic Rules of Inference

## Why Another Semantics?

Operational semantics:

- Describes *how* a program runs
- But only answers: "what happens on this run?"

Static semantics / Type systems:

- Guarantees safety ("won't get stuck")
- Cannot express runtime correctness

We need a way to state and prove:

- **"This program always produces the right result."**

## A Motivating Example

```ocaml
(fun x y -> if x <= y then y else x) 10 20
```

What we know:

- Operational semantics: evaluates to `20`
- Type System: expression has type `int`

We might want to assert:

- *For all inputs `x` and `y`, the function returns max(`x`,`y`)*

I.e., we need to be able to talk about *all* executions, not just one

## An Imperative Example

```pascal
f := 1;
i := 1;

while i <= N do
  f := f * i;
  i := i + 1;
```

Prove that ∀ `N` ≥ 0, the loop terminates with `f` = `N`!

To do this, we must be able to make logical assertions about the environment
before and after each statement.

## Hoare Triples (Imperative)

```typst +render +width:30%
$
{P} thick C thick {Q}
$
```

- `P` and `Q` are logical predicates
- `C` is a language construct

Meaning: if `P` holds before `C` and `C` terminates, then `Q` holds afterwards

- assertion of *partial* correctness

## Total correctness

```typst +render +width:30%
$
[P] thick C thick [Q]
$
```

Meaning: if `P` holds before `C` then `C` *will terminate* and `Q` holds
afterwards

- this can be much harder (and in general, *impossible*) to prove
- we typically focus on partial correctness

In a program without loops/recursion, {`P`} `C` {`Q`} ⇔ [`P`] `C` [`Q`]

## Axiomatic Rules of Inference

### Assignment

```typst +render +width:40%
$
{?} thick x ":=" e thick {?}
$
```

How can we relate pre- and post-conditions around assignment?

Consider:

- { ? } x := y { x > 10 }

- { y + z < 100 } x := y + z { ? }

```typst +render +width:50%
$
{thick [e\/x] thick Q thick} thick x ":=" e thick {Q}
$
```

- looks like the opposite of what it should be!

E.g., derive a precondition `P` in {`P`} `C` {`Q`}, where `C` = `x := y * 2`\
and `Q` = `x < 10`

- is it the only precondition that works?
- what is special about the precondition derived by the rule?

### Sequencing

```typst +render +width:50%
$
({P} thick C_1 thick {R} quad {R} thick C_2 thick {Q})
/({P} thick C_1 ; C_2 thick {Q})
$
```

E.g., derive a precondition P in {`P`} `C` {`Q`}, where:

- `C` = `w := x; x := y; y := w;`

- `Q` = `x = 20 ∧ y = 10`

### Conditional

```typst +render +width:70%
$
({P and b} thick C_1 thick {Q} quad {P and not b} thick C_2 thick {Q})
/({P} thick "if" b "then" C_1 "else" C_2 thick {Q})
$
```

- Clever way to think about branches: `then` and `else` clauses work to ensure a
  common goal (`Q`)

  - vs. `n` conditionals leading to `2ⁿ` possible outcomes!

Example:

```pascal {1,4,7,10}
{ ? }

if x <= y then
  { ? ∧ x <= y}
  m := y + 1
else
  { ? ∧ x > y}
  m := x + 1

{ m > x ∧ m > y }
```

Example:

```pascal {1,4,7,10}
{ ? }

if x <= y then
  { y + 1 > x ∧ y + 1 > y ∧ x <= y}
  m := y + 1
else
  { x + 1 > x ∧ x + 1 > y ∧ x > y}
  m := x + 1

{ m > x ∧ m > y }
```

Example:

```pascal {1,4,7,10}
{ ? }

if x <= y then
  { true ∧ x <= y}
  m := y + 1
else
  { true ∧ x > y}
  m := x + 1

{ m > x ∧ m > y }
```

Example:

```pascal {1,4,7,10}
{ true }

if x <= y then
  { true ∧ x <= y}
  m := y + 1
else
  { true ∧ x > y}
  m := x + 1

{ m > x ∧ m > y }
```

i.e., the program unconditionally computes `m` greater than `x` and `y`

## Strength of Assertions

Important idea in axiomatic semantics: "weak"/"strong" assertions

- the less restrictive an assertion, the *weaker* it is

- the more restrictive an assertion, the *stronger* it is

In a given Hoare triple {`P`} C {`Q`},

- the *weakest precondition* `P` describes the least restrictive assumptions
  under which the triple holds

- the *strongest postcondition* `Q` is the most precise description of the end
  result that always holds

## Weakening / Strengthening Assertions

- If `P` ⇒ `Q`, `P` is *stronger* than `Q` and `Q` is *weaker* than `P`

  - e.g., Rover is a dog ⇒ Rover is a mammal

  - e.g., (x = 7) ⇒ (x ≥ 0)

- Adding a *conjunction* to an assertion *strengthens it*

  - e.g., (x > 50) ∧ (y < 10) ⇒ (x > 50)

- Adding a *disjunction* to an assertion *weakens it*

  - e.g., (x > 50) ⇒ (x > 50) ∨ (z > 0)

### Consequence

```typst +render +width:60%
$
(P => P' quad {P'} thick C thick {Q'} quad Q' => Q)
/({P} thick C thick {Q})
$
```

I.e., we can *strengthen the precondition* or *weaken the postcondition*, and a
triple will still hold.

- this is useful when trying to prove/derive a Hoare triple

### Loop

```typst +render +width:60%
$
({P and b} thick C thick {P})
/({P} thick "while" b "do" C thick {P and not b})
$
```

- `P` is preserved across each loop iteration, and is also true before the loop
  and after it terminates

  - Known as the *loop invariant*

- Proving loop correctness requires establishing a loop invariant, and
  connecting it to the "goal" of the loop!

Example:

```pascal {4,7,10,12}
f := 1;
i := 1;

{ ? }

while i <= N do
  { ? ^ i <= N }
  f := f * i;
  i := i + 1;
  { ? }

{ ? ^ i > N }
```

Example:

```pascal {4,7,10,12}
f := 1;
i := 1;

{ f = (i-1)! }

while i <= N do
  { f = (i-1)! ^ i <= N}
  f := f * i;
  i := i + 1;
  { f = (i-1)! }

{ f = (i-1)! ^ i > N}
```

Example:

```pascal {4,7,10,12}
f := 1;
i := 1;

{ f = (i-1)! ^ i <= (N+1)}

while i <= N do
  { f = (i-1)! ^ i <= (N+1) ^ i <= N }
  f := f * i;
  i := i + 1;
  { f = (i-1)! ^ i <= (N+1) }

{ f = (i-1)! ^ i <= (N+1) ^ i > N }
```

Example:

```pascal {4,7,10,12}
f := 1;
i := 1;

{ f = (i-1)! ^ i <= (N+1)}

while i <= N do
  { f = (i-1)! ^ i <= (N+1) ^ i <= N }
  f := f * i;
  i := i + 1;
  { f = (i-1)! ^ i <= (N+1) }

{ f = (i-1)! ^ i = (N+1) }
```

Example:

```pascal {4,7,10,12}
f := 1;
i := 1;

{ f = (i-1)! ^ i <= (N+1)}

while i <= N do
  { f = (i-1)! ^ i <= (N+1) ^ i <= N }
  f := f * i;
  i := i + 1;
  { f = (i-1)! ^ i <= (N+1) }

{ f = N! }
```
