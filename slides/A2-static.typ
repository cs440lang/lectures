#show heading: set block(below: 1em)

#let bop = sym.plus.circle
#let mapto = sym.arrow.r.bar
#let tstile = sym.tack.r
#let rtstile = sym.tack.l

#let nonumeq = math.equation.with(block: true, numbering: none)
#let dm(x) = box[#nonumeq[#x]]
#let dfrac(x, y) = math.frac(dm(x), dm(y))

= Static Semantics (Typing Rules)

== Basic Notation

Building on the notation described in appendix A1, we use $tau$, $tau'$,
$tau_n$  for meta-variables ranging over arbitrary types, and $alpha$, $alpha'$,
$alpha_n$ for type variables occuring in language-level type expressions or type
signatures. $Gamma$ denotes a typing context.

#grid(
  columns: 2,
  gutter: 1em,
  align: (right, left),

  [$Gamma tstile e : tau$], [Under $Gamma$, $e$ has type $tau$],

  [$tstile e : tau$], [$e$ has type $tau$ in the empty context],

  [$Gamma(x)$], [Look up the type assigned to $x$ in $Gamma$],

  [$Gamma(x) = tau$], [In $Gamma$, $x$ is assigned type $tau$],

  [$Gamma[x mapto tau]$], [Extend $Gamma$ by assigning $x$ the type $tau$],

  [$Gamma tstile e : tau rtstile C$],
  [Under $Gamma$, $e$ is inferred to have type $tau$ and generates
    constraint set $C$],

  [fresh $alpha$],
  [$alpha$ is a _freshly generated_ type variable -- i.e., it
    is not used elsewhere],
)

#pagebreak()

== Type Checking

In our type-checked language, unlike SimPL and MiniML, functions must declare
their parameter types explicitly. I.e., functions are defined thusly:
`fun var : type -> body`. This is reflected in the "FUN" rule, below.


$
     "INT" & () / (Gamma tstile i in ZZ : "int") \
           \
  "BOOL-T" & () / (Gamma tstile "true" : "bool") \
           \
  "BOOL-F" & () / (Gamma tstile "false" : "bool") \
           \
     "VAR" & (Gamma(x) = tau) / (Gamma tstile x : tau) \
           \
   "BOP-I" & (bop in {+,*}
             quad Gamma tstile e_1 : "int"
             quad Gamma tstile e_2 : "int")
             / (Gamma tstile e_1 bop e_2 : "int") \
           \
   "BOP-B" & (bop in {<=}
             quad Gamma tstile e_1 : "int"
             quad Gamma tstile e_2 : "int")
             / (Gamma tstile e_1 bop e_2 : "bool") \
           \
      "IF" & (Gamma tstile e_1 : "bool"
             quad Gamma tstile e_2 : tau
             quad Gamma tstile e_3 : tau)
             / (Gamma tstile "if" e_1 "then" e_2 "else" e_3 : tau) \
           \
     "LET" & (Gamma tstile e_1 : tau_1
             quad Gamma[x mapto tau_1] tstile e_2 : tau_2)
             / (Gamma tstile "let" x=e_1 "in" e_2 : tau_2) \
           \
     "FUN" & (Gamma[x mapto tau] tstile e : tau')
             / (Gamma tstile "fun" x : tau "->" e : tau -> tau') \
           \
     "APP" & (Gamma tstile e_1 : tau -> tau'
             quad Gamma tstile e_2 : tau)
             / (Gamma tstile e_1 e_2 : tau')
$

#pagebreak()

== Type Inference

The rules below are for type inference of MiniML.

$
     "INT" & () / (Gamma tstile i in ZZ : "int" rtstile {}) \
           \
  "BOOL-T" & () / (Gamma tstile "true" : "bool" rtstile {}) \
           \
  "BOOL-F" & () / (Gamma tstile "false" : "bool" rtstile {}) \
           \
     "VAR" & (Gamma(x) = tau) / (Gamma tstile x : tau rtstile {}) \
           \
   "BOP-I" & (bop in {+,*}
             quad Gamma tstile e_1 : tau_1 rtstile C_1
             quad Gamma tstile e_2 : tau_2 rtstile C_2)
             / (Gamma tstile e_1 bop e_2 : "int"
             rtstile C_1 union C_2
             union { tau_1 = "int", tau_2 = "int"}) \
           \
   "BOP-B" & (quad Gamma tstile e_1 : tau_1 rtstile C_1
             quad Gamma tstile e_2 : tau_2 rtstile C_2)
             / (Gamma tstile e_1 <= e_2 : "bool"
             rtstile C_1 union C_2
             union { tau_1 = "int", tau_2 = "int"}) \
           \
      "IF" & ("fresh" alpha
             quad Gamma tstile e_1 : tau_1 rtstile C_1
             quad Gamma tstile e_2 : tau_2 rtstile C_2
             quad Gamma tstile e_3 : tau_3 rtstile C_3)
             / (Gamma tstile "if" e_1 "then" e_2 "else" e_3 : alpha
             rtstile C_1 union C_2 union C_3
             union { tau_1 = "bool", alpha=tau_2, alpha=tau_3}) \
           \
     "FUN" & ("fresh" alpha
             quad Gamma[x mapto alpha] tstile e : tau rtstile C)
             / (Gamma tstile "fun" x "->" e : alpha -> tau
             rtstile C) \
           \
     "APP" & ("fresh" alpha
             quad Gamma tstile e_1 : tau_1 rtstile C_1
             quad Gamma tstile e_2 : tau_2 rtstile C_2)
             / (Gamma tstile e_1 e_2 : alpha rtstile C_1 union C_2
             union { tau_1 = tau_2 -> alpha}) \
           \
  // "LET" & (Gamma tstile e_1 : tau_1 rtstile C_1
  // quad sigma = "unify"(C_1)
  // quad Gamma[ x mapto forall alpha . sigma(tau_1)] tstile e_2 : tau_2 rtstile C_2)
  // / (Gamma tstile "let" x = e_1 "in" e_2 : tau_2 rtstile C_1 union C_2)
$
