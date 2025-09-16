---
title: "OCaml: Lists"
author: "Michael Lee"
---

# Agenda

- Lists

---

# Lists

A list a sequence of elements *of the same type*

- implemented as singly-linked lists

- Type signature: `'a list`

---

# Lists

## List construction

Two constructors:

- Empty list: `[]`

- "Cons" operator: `::`

  - Type signature: `'a -> 'a list -> 'a list`

  - Right associative

---

# Lists

## List construction

e.g., building lists

```ocaml
let l1 = []

let l2 = 1 :: 2 :: 3 :: []

let l3 = "hello" :: "world" :: []

let l4 = (1 :: 2 :: []) :: (10 :: 20 :: []) :: []
```

---

# Lists

## Syntactic sugar

We can also just write:

```ocaml
let l4 = [1; 2; 3; 4]

let l5 = [[1; 2]; [10; 20]]

let l6 = [(fun x -> x*2); (fun x -> x/2)]
```

---
