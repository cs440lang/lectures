---
title: "Research Directions in Programming Languages"
sub_title: "CS 440: Programming Languages"
author: "Michael Lee"
---

# Agenda

- Why PL research?
  - Curry-Howard Correspondence
- Three research themes
  1. Advanced Type Systems
  2. Effect Systems
  3. Formal Semantics & Verification
- Takeaways & Where to go next

---

# Why PL Research?

Goal: To create mathematically sound models for computation.

<!-- pause -->

Payoff: Drives fundamental advancements in software safety, performance, and
formal verification.

<!-- pause -->

Much of modern PL research is motivated by the *Curry-Howard Correspondence*

---

# Curry–Howard Correspondence

A foundational connection between *logic* and *computation*.

<!-- pause -->

Also known as:

- *Propositions-as-Types*
- *Proofs-as-Programs*

<!-- pause -->

Not just a fanciful philosophical notion! It has direct consequences for
language design and verification.

---

# Curry–Howard Correspondence

## Propositions ⇔ Types

We can "translate" between types and logical propositions:

<!-- pause -->

<!-- alignment: center -->

| Programming | Logic   |
| ----------- | ------- |
| 'a, 'b, 'c  | A, B, C |
| 'a -> 'b    | A ⇒ B   |
| 'a * 'b     | A ∧ B   |
| 'a \| 'b    | A ∨ B   |

---

# Curry–Howard Correspondence

## Propositions ⇔ Types

E.g., `fst` (and `snd`) ⇔ conjunction elimination

```typst +render +width:70%
#let tstile = sym.tack.r
$
"fst ::" (alpha * beta) -> alpha
wide <=> wide
A and B => A
$
```

<!-- pause -->

E.g., function application rule ⇔ modus ponens

```typst +render +width:100%
#let tstile = sym.tack.r
$
"APP"  (Gamma tstile e_1 : alpha -> beta
        quad Gamma tstile e_2 : alpha)
        / (Gamma tstile e_1 e_2 : beta)

wide <=> wide

(A => B quad A) / (B) "MP"
$
```

---

# Curry–Howard Correspondence

## Proofs ⇔ Programs

<!-- pause -->

A well-typed program proves the proposition represented by its type

- By providing evidence of a value that *inhabits* the type

<!-- pause -->

When you write a program, you are building a *constructive proof*

---

# Curry–Howard Correspondence

## Evaluation ⇔ Proof Normalization

Evaluating a program = simplifying a proof

<!-- pause -->

- β-reductions, substitutions, etc., leave proofs logically unchanged
  (preservation) but more streamlined

---

# Curry–Howard Correspondence

## Why do we care?

<!-- pause -->

A more expressive type system gives us a richer logical vocabulary

- Motivation for advanced type systems

<!-- pause -->

Typechecking = automated proof checking

- Program synthesis can be viewed as automated proof derivation

---

# 1. Advanced Type Systems

<!-- pause -->

Basic types classify *data* (e.g., `int`, `bool`)

<!-- pause -->

Advanced types declare and enforce additional *logic-based invariants*

<!-- pause -->

Examples:

- Refinement types
- Dependent types
- Linear types

---

# 1. Advanced Type Systems

## Refinement Types

<!-- pause -->

Refinement = *base type + logical predicate*

<!-- pause -->

- e.g., type could be `{ x:int | x >= 0 }` or `{ xs:list | length xs > 0 }`

<!-- pause -->

Types can describe runtime constraints which are statically checked

- Generates mathematical proofs (verification conditions) and verifies them
  using automated Satisfiability Modulo Theories (SMT) solvers

---

# 1. Advanced Type Systems

## Dependent Types

<!-- pause -->

Dependent types = *type definitions that depend on values*

<!-- pause -->

- Structural properties can be guaranteed at compile-time

<!-- pause -->

- e.g., a function that takes an int `n` and whose return type is an `int`
  matrix of size `n` x `n`

<!-- pause -->

Example: F* -- a proof-oriented language, supporting both refinement and
dependent types

---

# 1. Advanced Type Systems

## Linear Types

<!-- pause -->

Enforce a "use exactly once" contract for resources in a program  

<!-- pause -->

- Prevents memory leaks, double-free errors, and resource contention

<!-- pause -->

Example: Rust's Borrow Checker

- compiler statically enforces ownership and borrowing semantics

- guarantees memory safety and data-race freedom without needing garbage
  collection

---

# 2. Effect Systems

<!-- pause -->

Purely functional systems allow for maximum compiler optimization (e.g., safe
automatic parallelization), but aren't always practical

<!-- pause -->

How to model *impure behavior* (state mutations, I/O, non-determinism) *without
sacrificing functional purity*?

<!-- pause -->

- Popular approach (e.g., in `Haskell`): Monads and Monad transformers

- Modern direction: Algebraic effects and handlers

---

# 2. Effect Systems

## Algebraic Effects and Handlers (AEH)

Effect operations (e.g., `read_file`) carry no inherent behavior; the behavior
is defined dynamically by the nearest handler (similar to exception handling)

<!-- pause -->

- Functions stay pure and declarative, while handlers supply the effect’s actual
  behavior

<!-- pause -->

- AEH gives us modular effects, customizable control flow (using continuations),
  and clean semantics

---

# 2. Effect Systems

## Algebraic Effects and Handlers (AEH)

E.g., `Eff` is a OCaml-based language that natively supports AEH:

```ocaml
handle
    perform (Print "A");
    perform (Print "B");
    perform (Print "C");
    perform (Print "D")
with
| effect (Print msg) k ->
    perform (Print ("Printing " ^ msg));
    continue k () (* explicitly resume execution *)
;;
```

---

# 3. Formal Semantics & Verification

<!-- pause -->

Aim to *rigorously prove* important system properties (correctness, security)
using mathematical models

<!-- pause -->

Some notable directions:

- verified compilers
- behavioral types
- differentiable programming

---

# 3. Formal Semantics & Verification

## Verified Compilers

<!-- pause -->

High-level proofs are useless if the compiler introduces bugs!

<!-- pause -->

Verified compilers *mathematically prove* that the compilation process preserves
semantics

<!-- pause -->

- e.g., the CompCert C compiler "comes with a mathematical, machine-checked
  proof that the generated executable code behaves exactly as prescribed by the
  semantics of the source program"
  - used in avionics, automotive, crypto

---

# 3. Formal Semantics & Verification

## Behavioral Types

<!-- pause -->

Types that describe **how a program behaves**, not just what values it computes.

- A type can encode *temporal*, *communication*, or *resource* behavior.

<!-- pause -->

Behavioral types extend standard soundness:

- Preservation: protocols are followed
- Progress: no illegal states

---

# 3. Formal Semantics & Verification

## Differentiable Programming (DP)

<!-- pause -->

Programming languages where *differentiation is built into the semantics*

<!-- pause -->

Motivation:

- Machine learning relies on gradients

- Correct gradients are essential

<!-- pause -->

Automatic Differentiation (AD) = program transformation

- Differentiable programming gives AD a formal semantics

- e.g., systems like TensorFlow and languages such as JAX, Dex, or Swift for
  TensorFlow

---

# The Future is Formally Verified!

PL research increasingly shifts correctness enforcement from post-hoc testing to
design time and compile time

<!-- incremental_lists: true -->

- Types are now *powerful logical tools* (Refinement, Dependent, Linear)

- *Effects* are tamed compositionally (Algebraic Handlers)

- *Formal Semantics* guarantees correctness from source code down to compiled
  machine code (Verified Compilers)

---

# Foundations

All modern PL research builds on:

- λ-calculus
- Type systems
- Operational semantics
- Interpreter and compiler design
- Formal reasoning

<!-- pause -->

These are not historical. This *is* the modern toolkit.

---

# Where to go next?

- *Coursework*: take the FP class (CS 340), compiler course (CS 443), or
  "science of programming" (CS 536)

- *Personal projects*: play with advanced types/type-systems or experimental
  languages for a glimpse of the future

- *Undergraduate research*: talk to PL faculty (Dr. Derakhshan and Dr. Korel)
  for research opportunities

---

<!-- jump_to_middle -->

<!-- alignment: center -->

*That's all, folks!*
