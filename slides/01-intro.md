---
title: "OCaml: Introduction and Basics"
author: "Michael Lee"
---

# Agenda

- OCaml toplevel/playground
- High-level language features
- Sample code and lecture workflow
- OCaml basics
  - Expressions, Values, and Types
  - Errors and Exceptions
  - Built-in types and operators
  - Let expressions and Variable bindings

---

# OCaml toplevel: `utop`

- REPL for OCaml
  - Handy for evaluating small expressions and "live" interactions with
    functions defined in source files
- Typical workflow: edit source file, (re)load in `utop`, interact/test
- Syntax and semantics between top-level and "normal" OCaml are slightly
  different!
- If you don't have OCaml installed, you can use the
  [OCaml playground](https://ocaml.org/play)

---

# Some notable Language Features

- *Static-typing* and *Type-safety*
- *Type-inference*
- *First-class functions*
- *Algebraic data types*
- *Pattern matching*
- *Parametric polymorphism*
- *Garbage collection*

---

## Static-typing and Type-safety

- Every expression has a type, determined at compile time
- Many errors are caught before running the program
- Prevents operations on incompatible types

```ocaml
let x = 5 + 2

let y = "hello" + 3   (* compile-time error *)
```

---

## Type-inference

- Compiler deduces types automatically
- No need to annotate unless desired

```ocaml
let square x = x * x
(* inferred type: int -> int *)
```

---

## First-class functions

- Functions are treated like any other value:
  - Can be assigned to variables
  - Passed as arguments
  - Returned from other functions

```ocaml
let inc x = x + 1

let apply_twice f x = f (f x)

apply_twice inc 3   (* evaluates to 5 *)
```

---

## Algebraic data types

- Custom types built from simpler ones
  - Simple, but powerful paradigm for defining types

```ocaml
type color =
  | Red
  | Green
  | Blue

type shape = Circle of color | Square of color;; 

let s : shape = Circle Blue
```

<!-- pause -->

```ocaml
type point = float * float

let p : point = (2.0, -3.5)
```

---

## Pattern matching

- Case analysis on data values
- Concise and expressive way to deconstruct values

```ocaml
let describe c =
  match c with
  | Red -> "warm"
  | Green -> "fuzzy"
  | Blue -> "cool"

describe Red   (* "warm" *)
```

---

## Parametric polymorphism

- Functions work uniformly on values of many types
- Represented with type variables (`'a`, `'b`, etc.)

```ocaml
let id x = x
(* type: 'a -> 'a *)

let swap (x, y) = (y, x)
(* type: 'a * 'b -> 'b * 'a *)
```

---

## Garbage collection

- Automatic memory management
- Frees unused memory so programmers don’t have to
- Safer than manual memory management

```ocaml
let make_big_list n =
  Array.init n (fun i -> i)

(* Memory is reclaimed when list is no longer reachable *)
```

---

# OCaml basics

- Expressions, Values, and Types
- Syntax errors, Type errors, and Exceptions
- Some built-in types
- Let expressions and Variable bindings

---

## Expressions, Values, and Types

- *Expression*: any valid piece of OCaml code that produces a value
- *Value*: a fully evaluated result (cannot be reduced further)
- *Type*: classification of values and expressions

```ocaml
42          (* expression & value of type int *)

3 + 4       (* expression of type int, value 7 *)

"hi" ^ "!"  (* expression of type string, value "hi!" *)
```

- *Evaluating* an expression may:
  - Produce a value
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

```ocaml
let x = 1 +   (* Error: unexpected end of input *)
```

---

### Type errors

Operations on incompatible types

- Caught by compiler statically (compile-time)

```ocaml
1 + "hello"   (* Error: int expected, string found *)
```

---

### Exceptions

Dynamic / Run-time

- should (some of these) be type errors?

```ocaml
1 / 0          (* Exception: Division_by_zero *)
```

- infinite loops/recursion

```ocaml
let rec forever () =
  forever ()

forever ()   (* never terminates *)
```

---

## Some built-in types

- `int`, `float`, `bool`, `char`, `string`
- Tuples: `(1, "hi", true)`
- Lists: `[1; 2; 3]`
- Options: `Some 42` or `None`
- Unit: `()`

---

### Some operators

- Integers: `+`, `-`, `*`, `/`
- Floats: `+.`, `-.`, `*.`, `/.`
- Booleans: `&&`, `||`, `not`
- Strings: `^` (concatenation)

```ocaml
3 + 4       (* int addition *)
3.0 +. 4.0  (* float addition *)
"hi" ^ "!"  (* string concatenation *)
```

---

## Let expressions

- Bind a name to a value
- Must be defined before use

```ocaml
let x = 10
let y = x + 5   (* y = 15 *)

let add a b = a + b
add 2 3         (* 5 *)
```

- *Shadowing*: new binding can reuse the same name, hiding the old one

```ocaml
let x = 1
let x = x + 2   (* now x = 3 *)
```
