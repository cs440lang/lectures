---
title: "OCaml: Higher Order Functions"
author: "Michael Lee"
---

# Agenda

- Def: Higher Order Function
- Some Basic HOFs
- `map` and `filter`
- Folds
- HOFs on Trees
- HOFs Returning Functions
- Closures

---

# Def: Higher Order Function

A Higher Order Function (HOF) is a function that either

- takes a function as an argument, or
- returns a function

---

# Some Basic HOFs

Apply:

```ocaml
let apply f x = f x
```

<!-- pause -->

Compose:

```ocaml
let compose f g = fun x -> f (g x)

(* or, equivalently *)
let compose f g x = f (g x)
```

<!-- pause -->

What are the types of `apply` and `compose`?

---

# `map` and `filter`

`map` accepts a function `f` and a list `l`, applies `f` to every item of `l`,
and returns a new list of the results

```ocaml
val map : ('a -> 'b) -> 'a list -> 'b list
```

<!-- pause -->

`filter` accepts a predicate `p` and a list `l`, and returns a list containing
only those elements for which `p` tests `true`

```ocaml
val filter : ('a -> bool) -> 'a list -> 'a list
```

---

# Folds

## Recursive list-processing

Consider the prototypical recursive list-processing function:

```ocaml
let rec proc = function
  | [] -> z
  | x :: xs -> f x (proc xs)
```

- `z` is the "base case" value
- `f` is a function that combines an element with the recursively obtained
  result

<!-- pause -->

What would `z` and `f` be for a "sum_list" function?

---

# Folds

## The Right Fold

The right fold distills the primitive recursive list-processing pattern into a
HOF:

```ocaml
let rec fold_right f z = function
  | [] -> z
  | x :: xs -> f x (fold_right f z xs)
```

<!-- pause -->

We call it the *right* fold, because the invocation:

```ocaml
fold_right f z [a; b; c; d; e]
```

results in the following expansion:

```ocaml
f a (f b (f c (f d (f e z))))
```

- `f` is applied in a *right-associative* manner to the list elements

---

# Folds

## The Right Fold

We can use `fold_right` to define recursive list-processing functions without
explicitly using recursion!

```ocaml
let sum lst = fold_right ( + ) 0 lst

let product lst = fold_right ( * ) 1 lst
```

---

# Folds

## Tail-recursive / Accumulating list-processing

Consider the prototypical tail-recursive list-processing function:

```ocaml
let rec tproc acc = function
  | [] -> acc
  | x :: xs -> tproc (f acc x) xs
```

- `acc` is the accumulator
- `f` combines the accumulated value with an element

---

# Folds

## The Left Fold

The left fold distills the tail-recursive list-processing pattern into a HOF:

```ocaml
let rec fold_left f acc = function
  | [] -> acc
  | x :: xs -> fold_left f (f acc x) xs
```

<!-- pause -->

We call it the *left* fold, because the invocation:

```ocaml
fold_left f acc [a; b; c; d; e]
```

results in the following expansion:

```ocaml
f (f (f (f (f acc a) b) c) d) e
```

- `f` is applied in a *left-associative* manner to the list elements

---

# Folds

## The Left Fold

We can use `fold_left` to define tail-recursive list-processing functions

```ocaml
let sum' lst = fold_left (+) 0 lst 

let product' lst = fold_left ( * ) 1 lst
```

---

# Folds

## Right vs. Left fold (on lists)

Right folds follow the natural associativity of the list `(::)` operator, so
yields the correct order when building a list result from an input list.

Left folds are tail-recursive, so are typically going to be faster and
more-efficient when possible.

If using a right- or left- associative operation as the function argument to a
fold, it makes sense to use the corresponding right- or left- fold HOF!

---

# HOFs on Trees

Recursive patterns over other types can be distilled into HOFs, too.

Consider our binary tree type from before:

```ocaml
type ('k,'v) bin_tree = Nil
                      | Node of 'k * 'v
                                * ('k,'v) bin_tree
                                * ('k,'v) bin_tree
```

What would `map` or `fold` operations on the tree look like?

---

# HOFs Returning Functions

Note that all functions of multiple arguments in OCaml are effectively HOFs,
because of currying!

Consider the meaning of the `function` keyword in the definition of `map`:

```ocaml
let rec map f = function
  | [] -> []
  | x :: xs -> f x :: map f xs
```

- i.e., if we call `map` with just `f`, it returns a new function!

So what does this mean?

```ocaml
let double = map (( * ) 2)
```

---

# HOFs Returning Functions

Here's a slightly more interesting HOF:

```ocaml
let adder x = let n = x in
              fun y -> n + y
```

- how do we use this?
- what happens with the variable `n` when `adder` returns?

---

# Closures

The function returned by `adder` *captures the environment* at the time the
function was created.

- this includes all values of free variable in the function body

```ocaml
let adder x = let n = x in
              fun y -> n + y
```

<!-- pause -->

We call this combination of a function and its environment a *Closure*.

- closures are created automatically
- closures are first-class -- you can pass them as arguments, return them, store
  them in data structures, etc.

---

# Closures

The function returned by `adder` *captures the environment* at the time the
function was created.

- this includes all values of free variable in the function body

```ocaml
let adder x = let n = x in
              fun y -> n + y
```

We call this combination of a function and its environment a *closure*.

- closures are created automatically
- closures are first-class -- you can pass them as arguments, return them, store
  them in data structures, etc.

---

# Closures

Closures are incredibly important and useful!

- they are implicit in every partial function application (why?)

- they allow functions returned by HOFs to have internal, encapsulated "state"

- they can be used to simulate many other useful constructs!

<!-- pause -->

E.g., closure as a mutable "object"

```ocaml
let make_counter init = let c = ref init in
                        fun () -> c := !c + 1 ; !c
```
