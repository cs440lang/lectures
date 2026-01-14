# Course Overview

## Agenda

- Faculty & Staff
- Course Overview
- Administrivia

## Faculty & Staff

Prof: *Michael Lee*

- Email: <lee@iit.edu>
- Homepage: <https://moss.cs.iit.edu>
- Hours: Tue/Thu 12:00-14:00

Office hours are by appointment only -- make appointments on my homepage. You can also reach out anytime via MS Teams for asynchronous help.

TA: Xincheng Yang <xyang76@hawk.illinoistech.edu>

The TA will grade all machine problems and is the first point of contact for questions about grading. Reach out to him on MS Teams with questions or to schedule a meeting.

## Course Overview

### "Programming Languages" (PLs)

Introduction to the rich field of *Programming Language Theory* (PLT).

Study of *programming languages*:

- In theory all the same (Turing-complete); in practice very different!

### PL Consumer -> PL *Designer*

- How can PLs help us program more effectively?

- What guides the design and implementation of PLs?

- How can we rigorously specify and reason about PL behavior?

- How are PLs compiled/interpreted?

### PL Paradigms

A language is often rooted in a single computational *paradigm* (even though it may be a *multi-paradigm* language), which profoundly influences how we reason about and write code in it.

- *Imperative*: prescriptive
  - i.e., *how* to compute
  - modeled on *incremental mutation* of machine state (variables)

- *Functional*: descriptive
  - i.e., *what* to compute
  - modeled on "pure" *mathematical functions*

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

This class shines a spotlight on the functional paradigm. We will use a multi-paradigm language that emphasizes FP: **OCaml**.

This will provide a *different perspective* on programming (for most students!)

It will force us to grapple with concepts/techniques that are unavailable (or optional) in imperative languages

- E.g., pattern matching, higher-order functions, closures

Many modern PLs are adopting historically "functional" features, and it's important to be familiar with them (and why they are important).

### PL Implementation

We will examine how PLs work under the hood.

To this end, we will build *interpreters* from scratch using OCaml.

- Workflow: *Lexing* -> *Parsing* -> *Internal Representation* -> *Type Checking* -> *Evaluation*

We will use standard tools like lexer & parser generators to automate some of these steps. OCaml has excellent support for language development!

This should give you insight into decisions and tradeoffs in PL design.

### PL Analysis

We will rigorously examine PL *semantics* from different angles:

- *Dynamic semantics* (when executed)

  - *Operational semantics*: what does a program evaluate to?

  - *Axiomatic semantics*: how can we reason about correctness?

- *Static semantics* (as written)

  - *Type systems* constrain the values that inhabit our programs, and let us rule out entire classes of errors before we ever run them!

There is a deep connection between types, logic, programs, and proofs that we will uncover by the end of the semester, that is the driving force behind much PL research!

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
- Different point values, weighted proportionally

#### Exams

There will be two exams, covering concepts and practical skills. Exams will be synchronous, in-person, and closed-device/closed-notes.

The midterm exam will take place on or around March 4th, and the final exam will take place during finals week (May 4-9).

At my discretion, I may apply a linear formula to normalize exam scores such that the maximum and average scores are adjusted to 100% and 75%.

### Resources

#### Canvas

You can find the following on Canvas:

- the lecture and assignment/exam schedule
- all assignment writeups and invitation links (for MPs)
- upload links for written assignments
- important announcements (you should get email notifications by default)

#### Lecture Repository

Located at <https://github.com/cs440lang/lectures/>. You will find:

- all lecture notes and handouts under `notes/`

  - notes are in Markdown format (view in GitHub or with some other Markdown preview tool)

    - Some notes contain math equation / diagram specifiations (in Typst, LaTeX, Mermaid, etc.) -- I will render these in my slides for you

  - all slides are distilled from the notes!

- source code used for demos during lecture are in `src/`

  - I'll go over how to load these into the OCaml REPL

- there are two branches:

  - `demo`: contains "starter" code that I use during in-class demos

  - `main`: contains the "final" (with spoilers) versions of code

I recommend that you clone the repository locally and create your own branch off of `main` to add your own notes and code/comments. Pull and merge my changes on a regular basis.

#### References

- Michael Clarkson, *OCaml Programming: Correct + Efficient + Beautiful*.
- Robert Harper, *Practical Foundations for Programming Languages*.
- Robert Nystrom, *Crafting Interpreters*.
- & slides, notes, and additional readings posted to Canvas!

## For Friday

Read Section 1 of *A Tutorial Introduction to the Lambda Calculus*, by Raul Rojas.
