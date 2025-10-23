---
title: "OCaml: Introduction and Basics"
author: "Michael Lee"
---

# Agenda

- Sample code and lecture workflow
- OCaml toplevel/playground
- Notable language features
- OCaml basics

---

# Sample code and Lecture workflow

Code repository: <https://github.com/cs440lang/lectures>

- Slides in `slides/`, Source code in `src/`

- Completed versions in `main` branch, Starter in `starter` branch

<!-- pause -->

Load starter code in OCaml toplevel during code demos to follow along

- Pull new changes from GitHub regularly!

---

# OCaml toplevel: `utop`

REPL for OCaml

- Typical workflow: edit source file, (re)load in `utop`, interact/test
- Syntax and semantics between top-level and "normal" OCaml are slightly
  different!

If you don't have OCaml installed, you can use the
[OCaml playground](https://ocaml.org/play)

---

# Notable Language Features

<!-- incremental_lists: true -->

1. *Static-typing* and *Type-safety*: every expression has a type, determined
   and enforced at compile time

2. *Type-inference*: the compiler can deduce types automatically

3. *First-class functions*: functions are treated like any other value

4. *Algebraic data types*: custom types are defined as "sums" and "products" of
   other types

5. *Pattern matching*: concise and expressive way of deconstructing values

6. *Parametric polymorphism*: functions can extend to disparate, unrelated types

---

# OCaml basics

- Defs: Expressions, Values, and Types
- Errors and Exceptions
- Some built-in types
- Variable bindings
- Conditionals

---

## Defs: Expressions, Values, and Types

- *Expression*: any valid piece of OCaml code that produces a value
- *Value*: a fully evaluated result (cannot be reduced further)
- *Type*: classification of values and expressions

```ocaml
42          (* expression & value of type int *)

3 + 4       (* expression of type int, value 7 *)

"hi" ^ "!"  (* expression of type string, value "hi!" *)
```

<!-- pause -->

- *Evaluating* an expression may:
  - Produce a value
    - In `utop`, evaluating a value also prints out its type
  - Produce an error

---

## Errors and Exceptions

What can go wrong?

1. Syntax errors
2. Type errors
3. Exceptions

---

### Syntax errors

Illegal/Malformed code

- Caught by the parser

E.g.,

```ocaml
let x = 1 +   (* Error: unexpected end of input *)
```

---

### Type errors

Operations on incompatible types

- Caught by compiler statically (compile-time)

E.g.,

```ocaml
1 + "hello"

2 * 2.0
```

---

### Exceptions

Dynamic / Run-time

- type system guarantees no type-related errors!

E.g., pre-defined exceptions

```ocaml
1 / 0  (* Division_by_zero *)

assert (delta < 0.0001)

failwith "Some error description ..."
```

<!-- pause -->

E.g., infinite loops/recursion

```ocaml
let rec loop () = loop ()

loop ()
```

---

## Some built-in types

- `int`, `float`, `bool`, `char`, `string`
- Tuples: `(1, "hi", true)`
- Lists: `[1; 2; 3]`
- Unit: `()`

---

## Some built-in types

### And their operators

- Integers: `+`, `-`, `*`, `/`
- Floats: `+.`, `-.`, `*.`, `/.`
- Booleans: `&&`, `||`, `not`
- Relational: `<`, `<=`, `>`, `>=`, `=`, `<>` (polymorphic)
- Strings: `^` (concatenation)
- Lists: `@` (concatenation)

```ocaml
3 + 4 

3.0 +. 4.0

"hi" ^ "!"

[1;2;3] @ [4;5;6]
```

---

## Variable bindings

`let` *binds* a name to a value

- Names must be defined before use

```ocaml
let x = 10

let y = x + 5   (* y = 15 *)
```

<!-- pause -->

A new binding can *shadow* an existing name:

```ocaml
let x = 1

let x = x + 2   (* now x = 3 *)
```

- this is *not* the same thing as mutating a variable!

---

## Variable bindings

### Type annotations

We can attach explicit type annotations to variables:

```ocaml
let x : int = 44

let y : int = 9 + 1

let z : int = x * y
```

- but we typically don't, because the compiler *infers* the correct types for
  us!
  - (how can it do so in the examples above?)

---

## Variable bindings

`let` can also be used with `in` to create a *scoped binding*:

```ocaml
let x = 44 in x * 10
```

- `x * 10` is the *body* of the `let`, and `x` is only valid in that scope.

<!-- pause -->

The entire `let-in` construct is itself an expression!

```ocaml
2 * (let x = 44 in x * 5)
```

<!-- pause -->

Nested `let`s are used to introduce multiple "local" variables:

```ocaml
let x = 44 in
  let y = 5 in
    2 * x * y
```

---

## Conditionals

`if-then-else` constructs a conditional expression:

```ocaml
if a*a + b*b = c*c then "square" else "not square"
```

<!-- pause -->

The entire `if-then-else` expression has some fixed type *t*, which means that
both `then` and `else` branches must evaluate to the same type *t*!

```ocaml
if foo < 10 then 10 else "bar" (* type error! *)
```

<!-- pause -->

It can be used anywhere an expression is legal!

```ocaml
let abs_x = x * (if x < 0 then -1 else 1)
```
