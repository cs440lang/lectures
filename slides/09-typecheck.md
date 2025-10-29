---
title: "Type Checking"
sub_title: "CS 440: Programming Languages"
author: "Michael Lee"
---

# Agenda

- Type Checking
- Typing Contexts and the Typing Relation
- Typing Rules
- A Type Checker for MiniML

---

```typst +render +width:60%
#let bop = sym.plus.circle
#let tstile = sym.tack.r

$
Gamma tstile e : t
$
```

---

```typst +render +width:60%
#let bop = sym.plus.circle
#let tstile = sym.tack.r

$
"INT"    & () / (Gamma tstile i in ZZ : "int") \

"BOOL-T" & () / (Gamma tstile "true" : "bool") \

"BOOL-F" & () / (Gamma tstile "false" : "bool") 
$
```

---

```typst +render +width:60%
#let bop = sym.plus.circle
#let tstile = sym.tack.r

$
"VAR"    & (x:t in Gamma) / (Gamma tstile x : t) \

"VAR"'    & () / (Gamma, x:t tstile x : t) \
$
```

---

```typst +render +width:80%
#let bop = sym.plus.circle
#let tstile = sym.tack.r

$
"BOP-I"  & (bop in {+,*}
            quad Gamma tstile e_1 : "int"
            quad Gamma tstile e_2 : "int")
           / (Gamma tstile e_1 bop e_2 : "int") \


"BOP-B"  & (bop in {<=}
            quad Gamma tstile e_1 : "int"
            quad Gamma tstile e_2 : "int")
           / (Gamma tstile e_1 bop e_2 : "bool")
$
```

---

```typst +render +width:80%
#let bop = sym.plus.circle
#let tstile = sym.tack.r

$
"IF"  (Gamma tstile e_1 : "bool"
       quad Gamma tstile e_2 : t
       quad Gamma tstile e_3 : t)
      / (Gamma tstile "if" e_1 "then" e_2 "else" e_3 : t)
$
```

---

```typst +render +width:80%
#let bop = sym.plus.circle
#let tstile = sym.tack.r

$
"LET" (Gamma tstile e_1 : t
       quad Gamma, x:t tstile e_2 : t')
      / (Gamma tstile "let" x=e_1 "in" e_2 : t')
$
```

---

```typst +render +width:80%
#let bop = sym.plus.circle
#let tstile = sym.tack.r

$
"FUN" (Gamma,x:t tstile e : t')
      / (Gamma tstile "fun" x "->" e :  t -> t')
$
```

---

```typst +render +width:80%
#let bop = sym.plus.circle
#let tstile = sym.tack.r

$
"APP" (Gamma tstile e_1 : t -> t'
       quad Gamma tstile e_2 : t)
      / (Gamma tstile e_1 e_2 : t')
$
```
