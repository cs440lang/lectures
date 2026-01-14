# OCaml: Data Types

## Agenda

- Tuples
- Records
- Type synonyms
- Algebraic data Types (ADTs)

## Tuples

A *tuple* is a *fixed-size*, *ordered* collection of values that can be of
different types.

- The type of a tuple is written as the *product* of the types of its components

- A tuple value is written as the components in parentheses, separated by commas

## Examples of Tuples

```ocaml
(1,2);;
- : int * int = (1, 2)

("hello", 5.0, true);;
- : string * float * bool = ("hello", 5., true)

((1,false), ["foo"; "bar"]);;
- : (int * bool) * string list = ((1, false), ["foo"; "bar"])
```

## Accessing tuple components

We use pattern-matching to access tuple components. E.g.,

```ocaml
let dist (x1,y1) (x2,y2) = sqrt ((x1-.x2)**2. +. (y1-.y2)**2.)

val dist : float * float -> float * float -> float
```

## Records

A *record* is a *fixed-size* collection of *named fields*, each with an
associated type.

- The type of a record is written with each field name and type listed inside {
  ... }.

- A record value is written like this: `{ field1 = v1; field2 = v2; ... }`.

- Fields are accessed by name using the `.` operator.

## Examples of Record Syntax

```ocaml
type student = { name : string; id : int; gpa : float; }

let michael = { name="Michael"; id=1234567; gpa=3.5 };

michael.id

(* we can also pattern match on records *)
match michael with {name; id; gpa} -> name;;

(* we can create new records from existing ones *)
{michael with name="Jane"; id=2345678};;
```

## Type synonyms

We can define *type synonyms* to help with legibility:

```ocaml
type point = float * float

val dist : point -> point -> float

type int_matrix = (int list) list

(* type synonyms can also be polymorphic! *)
type 'a matrix = ('a list) list
```

## Algebraic data types (ADTs)

An algebraic data type is a user-defined type that can take one of several
distinct *variants*, each of which may *carry zero or more values* (of possibly
different types).

- An ADT is defined using the type keyword and the `|` symbol to separate
  variants.

- Each variant is introduced by a *constructor*, which can optionally hold data.

- ADTs are used with pattern matching to inspect and decompose values.

## Examples of ADTs

```ocaml
type color = Red | Blue | Green

let describe_color = function
  | Red -> "Warm"
  | Blue -> "Cool"
  | Green -> "Verdant"

type shape = Circle of float
           | Rectangle of float * float
           | Triangle of float * float

let shape_area = function
  | Circle r -> Float.pi *. r *. r
  | Rectangle (l,w) -> l *. w
  | Triangle (b,h) -> b *. h /. 2.0
```
