---
title: "OCaml: Functions"
sub_title: "CS 440: Programming Languages"
author: "Michael Lee"
---

# Agenda

- Functions: definition and application
  - Anonymous functions
  - Function types
  - Equivalence to `let-in`
  - Currying and Partial application
  - Polymorphic functions
- Recursive functions
- Tracing function calls
- Operators as functions
- Application operators: `|>`, `@@`
- Tail recursion

---

# Functions: definition and application

## "Anonymous" functions

Functions in OCaml are values we can create with the `fun` keyword:

```ocaml
let inc = fun x -> x + 1

let foo = fun x y z -> (2*x + y) * z
```

- Note that these functions are *anonymous* -- they only have "names" because we
  bind variables to them.

- What are the function types? How do we interpret them?

  - e.g., `int -> int`, `int -> int -> int`

---

# Functions: definition and application

## Function types

- `t1 -> t2` is a type signature for a function that takes a value of type `t1`
  and returns a value of type `t2`

- `t1 -> t2 -> t3` describes a function that takes a value of type `t1` and
  returns a function of type `t2 -> t3`!

  - I.e., the `->` operator is right associative --- so `t1 -> t2 -> t3` is the
    same thing as `t1 -> (t2 -> t3)`

---

# Functions: definition and application

## Equivalence to `let-in`

Note that `let-in` is really just *syntactic sugar* for the application of a
corresponding anonymous function to the binding expression:

```ocaml
let x = 10 in 2 * x

(* is equivalent to *)

(fun x -> 2 * x) 10
```

- More evidence of the primacy of the function!

---

# Functions: definition and application

## Currying

Note the equivalence of the types of:

```ocaml
let foo = fun x y z -> (2*x + y) * z

let foo' = fun x -> fun y -> fun z -> (2*x + y) * z
```

- We say that functions of multiple arguments are *curried* in OCaml --- i.e.,
  it is turned into multiple functions of one argument, each of which returns
  another function of one argument (except for the last, which evaluates to the
  result)

---

# Functions: definition and application

## Partial application

A consequence of *currying* is that functions of multiple arguments can be
*partially applied*.

```ocaml
let foo = fun x y z -> (2*x + y) * z

let bar = foo 10

let baz = foo 10 20
```

What do `bar` and `baz` do? What are their types?

---

# Functions: definition and application

## Some syntactic sugar

There is an alternative syntax for defining functions:

```ocaml
let inc = fun x -> x + 1

(* is equivalent to ... *)

let inc' x = x + 1


let foo = fun x y z -> (2*x + y) * z

(* is equivalent to ... *)

let foo' x y z = (2*x + y) * z
```

---

# Functions: definition and application

Here's another example that helps illustrate the utility of partial application:

```ocaml
let dist (x1,y1) (x2,y2) = sqrt ((x2-.x1)**2.+.(y2-.y1)**2.)

let distFromOrigin = dist (0.0,0.0)
```

---

# Functions: definition and application

## Polymorphic functions

What is the type of the following function (identity)? How do we interpret it?

```ocaml
let id x = x
```

---

# Functions: definition and application

## Polymorphic functions

Here are a few more polymorphic functions to interpret:

```ocaml
let first x _ = x

let second _ y = y
```

- Note that we use `_` as the name for a parameter we don't plan to use in the
  function body.

---

# Functions: definition and application

## Polymorphic functions

If we wish, we can add type annotations that override the general nature of
naturally polymorphic functions:

```ocaml
let id (x : int) = x
```

---

# Recursive functions

What happens when you try to define a recursive function?

```ocaml
let fact n = if n <= 1 then 1 else n * fact (n-1)

(* Error: Unbound value fact *)
```

This is the same error we get when we try to do:

```ocaml
let x = x + 1
```

i.e., names must be bound *before* we try to refer to them!

---

# Recursive functions

We need to use the `rec` keyword to explicitly let OCaml know that we want to
permit self-referential definitions (i.e., recursion):

```ocaml
let rec fact n = if n <= 1 then 1 else n * fact (n-1)
```

But we'll run into a similar problem if we try to write *mutually-recursive*
functions:

```ocaml
let rec even n = if n = 0 then true
                 else odd (n-1)

let rec odd n  = if n = 0 then false 
                 else even (n-1)
```

---

# Recursive functions

For bindings that need to be able to refer to themselves and each other, we must
use the `rec` and `and` keywords (think of this as *parallel* binding):

```ocaml
let rec even n = if n = 0 then true
                 else odd (n-1)

    and odd n  = if n = 0 then false 
                 else even (n-1)
```

---

# Tracing function calls

We can *trace* function calls with the `#trace` top-level command.

- E.g., try `#trace fact`, `#trace even`, `#trace odd`, then calling the
  functions. Interpret the results.

- E.g., try `#trace foo`, then calling the function. Interpret the results.

Note that sometimes `#trace` can cause undesired side-effects in functions being
traced!

---

# Operators as functions

Operators can be treated as functions if we place them in parentheses:

```ocaml
(+) 10 32 (* evaluates to 42 *)

let plus = (+)  (* plus refers to the + function *)
```

- Note: this allows operators to be partially applied!

---

# Operators as functions

We can even define our own operators:

```ocaml
let (+++) x y = x + 3*y

10 +++ 5 (* evaluates to 15 *)
```

- but OCaml doesn't have a robust way of controlling precedence

---

# Application operators: `|>`, `@@`

There are a couple of very useful function-application related operators.

- `|>` - "pipeline"
- `@@` - apply

What are their types? Can you figure out how to use them?

---

# Tail recursion

Check out another recursive function.

```ocaml
let rec sum n = if n = 0 then 0
                else n + sum (n-1)
```

Try `sum 100_000_000` -- what happens? Why?

---

# Tail recursion

We can rewrite `sum` which uses an *accumulator* to avoid needing to do work
upon returning from recursive calls. (How do we call this?)

```ocaml
let rec sum' n acc = if n = 0 then acc
                     else sum' (n-1) (acc+n)
```

Does `sum' 100_000_000` work?

---

# Tail recursion

## Tail-Call Optimization (TCO)

```ocaml
let rec sum' n acc = if n = 0 then acc
                     else sum' (n-1) (acc+n)
```

We say that the recursive call above is in the "tail position" --- i.e., it is
the *last thing* done in the function body

- When this is the case, OCaml can perform *tail-call optimization*, which
  prevents additional stack frames from being allocated on recursive calls

---

# Tail recursion

But this implementation is ugly -- it exposes the accumulator (which can be
misused):

```ocaml
let rec sum' n acc = if n = 0 then acc
                     else sum' (n-1) (acc+n)
```

How can we clean it up?

---

# Tail recursion

## Auxiliary "helper" function

A cleaner implementation "hides" the accumulator by introducing an auxiliary
recursive function:

```ocaml
let sum'' n =
  let rec aux k acc = if k = 0 then acc
                      else aux (k-1) (acc+k) 
  in aux n 0
```

---

# Tail recursion

## Exercise

Can you write an efficient, tail-recursive version of the following Fibonacci
generator?

```ocaml
let rec fib n = if n = 0 then 1
                else if n = 1 then 1
                else fib (n-1) + fib (n-2)
```
