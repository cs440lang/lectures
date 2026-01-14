# Course Overview

## Agenda

- Faculty & Staff
- Course Overview
- Administrivia

## Faculty & Staff

Prof:

- *Michael Lee* lee@iit.edu
- Homepage: http://moss.cs.iit.edu
- Hours: TBA

TA:

- TBA

## Course Overview

### "Programming Languages" (PLs)

Introduction to the field of *Programming Language Theory* (PLT).

Study of *programming languages*:

- In theory all the same (Turing-complete); in practice very different!

### PL Consumer -> PL *Designer*

- How can PLs help us program more effectively?

- What guides the design and implementation of PLs?

- How can we rigorously specify and reason about PL behavior?

- How are PLs compiled/interpreted?

### PL Paradigms

- *Imperative*: prescriptive
  - i.e., *how* to compute
  - modeled on *incremental mutation* of machine state (variables)

- *Functional*: descriptive
  - i.e., *what* to compute
  - modeled on "pure" *mathematical functions*

E.g., Imperative vs. Functional

e.g., *Imperative*

```python
def sum(lst):
  s = 0
  i = 0
  while i < len(lst):
    s += lst[i]
    i = i + 1
  return s
```

e.g., *Functional*

```haskell
sum []     = 0
sum (n:ns) = n + sum ns
```

### Spotlight on the Functional Paradigm

- A *different perspective* on programming (for most students!)

- Forces us to grapple with concepts/techniques that are unavailable or optional in most imperative languages

  - E.g., type inference, pattern matching, higher-order functions

  - Many modern PLs are adopting historically "functional" features!

### PL Implementation

- Understand how PLs work under the hood

- Build *interpreters* from scratch using OCaml

  - *Lexing*/*Parsing* -> *Abstract Syntax Trees* -> *Evaluation*

  - Gain insight into decisions and tradeoffs in PL design

### PL Analysis

- Rigorous treatment of PL *semantics*

- *Dynamic semantics* (when executed)

  - *Operational semantics*: what does a program evaluate to?

  - *Axiomatic semantics*: how can we reason about correctness?

- *Static semantics* (as written)

  - *Type systems* constrain the values that inhabit our programs, and let us rule out entire classes of errors before we ever run them!

### By the end ...

- You'll have implemented *multiple interpreters*, *type checking*, and *polymorphic type inference*

- You'll understand how fundamental PL features (closures, recursion, type inference) *actually work* under the hood

- You'll be able to read and write *formal specifications* of PL behavior

- You'll be equipped to *critically evaluate* language design decisions in any language you use

## Administrivia

### Prerequisites & Foundational Knowledge

- Substantial programming experience
- Propositional and First-order logic (CS 330)
- Mathematical induction (CS 330 / 430)
- Formal languages and Grammars (CS 330)
- Data structures and Algorithms (CS 331 / 430)

### Assessments and Grading

Final grades are broken down as follows:

- 50% Assignments
- 25% Midterm Exam
- 25% Final Exam

And here is the grade scale:

- A ≥ 90%
- B ≥ 80%
- C ≥ 70%
- D ≥ 60%
- E < 60%

#### Assignments

- ~4 machine problems (MPs) -- coding exercises
- ~3 written problem sets -- evaluation / derivation / proofs
- All posted to Canvas; MPs distributed via Git
- Different point values, weighted proportionally

#### Exams

There will be two exams, covering concepts and practical skills. Exams will be synchronous, in-person, and closed-device/closed-notes. The midterm exam will take place on or around March 13th (just before spring break), and the final exam will take place during finals week (May 4-9).

At my discretion, I may apply a linear formula to normalize exam scores such that the maximum and average scores are adjusted to 100% and 75%.

### References

- Michael Clarkson, *OCaml Programming: Correct + Efficient + Beautiful*.
- Robert Harper, *Practical Foundations for Programming Languages*.
- Robert Nystrom, *Crafting Interpreters*.
- & slides, notes, and additional readings posted to Canvas!

## For Friday

Read Section 1 of *A Tutorial Introduction to the Lambda Calculus*, by Raul Rojas.
