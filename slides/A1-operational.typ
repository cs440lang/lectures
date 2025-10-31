#show heading: set block(below: 1em)

#let bop = sym.plus.circle
#let mapto = sym.arrow.r.bar
#let bstep = sym.arrow.b.double
#let state(e, s) = { $angle.l #e,#s angle.r$ }

#let nonumeq = math.equation.with(block: true, numbering: none)
#let dm(x) = box[#nonumeq[#x]]
#let dfrac(x, y) = math.frac(dm(x), dm(y))

= Operational Semantics (Small- and Big-Step Rules)

== Basic Notation

We use $x$ to denote variables in the language, $e$, $e'$, $e_n$
to denote expressions, $v$, $v'$, $v_n$ to denote values, and
$sigma$, $sigma'$ to represent the dynamic environment.


#grid(
  columns: 2,
  gutter: 1em,
  align: (right, left),

  [$[e_1\/x]e_2$], [Substitute $e_1$ for free instances of $x$ in $e_2$],
  [$e -> e'$], [$e$ reduces to $e'$ in one step],
  [$e cancel(->)$], [$e$ cannot be further reduced],
  [$e ~> v$], [$e$ reduces to $v$ in zero or more steps],
  [$e bstep v$], [$e$ evaluates to $v$],
  [$sigma(x)$], [Look up the value of $x$ in $sigma$ (error if unmapped)],

  [$sigma[x mapto v]$], [Extend $sigma$ to include a binding from $x$ to $v$],

  // [Update the environment to include the $x mapto v$ mapping],

  [$state(e, sigma) -> e'$], [$e$ in $sigma$ reduces to $e'$],
  [$state(e, sigma) cancel(->)$], [$e$ in $sigma$ cannot be reduced],
  [$state(e, sigma) bstep v$], [$e$ in $sigma$ evaluates to value $v$],
)

#pagebreak()

== SimPL

=== Substitution Model

==== Small-Step Semantic Rules

$
    "INT" & (i in ZZ) / (i cancel(->)) \
   "BOOL" & (b in {"true", "false"}) / (b cancel(->)) \
    "VAR" & () / (x cancel(->)) \
  "BOP-L" & (e_1 -> e'_1) / (e_1 bop e_2 -> e'_1 bop e_2) \
  "BOP-R" & (e_1 cancel(->) quad e_2 -> e'_2) /
            (e_1 bop e_2 -> e_1 bop e'_2) \
  "BOP-E" & (e_1 cancel(->) quad e_2 cancel(->))
            / (e_1 bop e_2 -> (e_1 bop e_2)) \
   "IF-G" & (e_1 -> e'_1)/
            ("if" e_1 "then" e_2 "else" e_3 -> "if" e'_1 "then" e_2 "else" e_3) \
   "IF-T" & () / ("if true then" e_2 "else" e_3 -> e_2) \
   "IF-F" & () / ("if false then" e_2 "else" e_3 -> e_3) \
  "LET-V" & (e_1 -> e'_1) /
            ("let" x=e_1 "in" e_2 -> "let" x=e'_1 "in" e_2) \
  "LET-B" & (e_1 cancel(->)) /
            ("let" x=e_1 "in" e_2 -> [e_1\/x]e_2) \
$

==== Big-Step Semantic Rules

$
   "INT" & (i in ZZ)/(i bstep i) \
  "BOOL" & (b in {"true", "false"})/(b bstep b) \
   "VAR" & () / (x cancel(arrow.b.double)) \
   "BOP" & (e_1 bstep v_1 quad e_2 bstep v_2) /
           (e_1 bop e_2 bstep (v_1 bop v_2)) \
  "IF-T" & (e_1 bstep "true" quad e_2 bstep v_2) /
           ("if" e_1 "then" e_2 "else" e_3 bstep v_2) \
  "IF-F" & (e_1 bstep "false" quad e_3 bstep v_3) /
           ("if" e_1 "then" e_2 "else" e_3 bstep v_3) \
   "LET" & (e_1 bstep v_1 quad [v_1\/x]e_2 bstep v_2) /
           ("let" x=e_1 "in" e_2 bstep v_2) \
$

== SimPL

=== Environment Model

==== Big-Step Semantic Rules

$
   "INT" & (i in ZZ)/(state(i, sigma) bstep i) \
  "BOOL" & (b in {"true", "false"})/(state(b, sigma) bstep b) \
   "VAR" & () / (state(x, sigma) bstep sigma(x)) \
   "BOP" & (state(e_1, sigma) bstep v_1 quad state(e_2, sigma) bstep v_2) /
           (state(e_1 bop e_2, sigma) bstep (v_1 bop v_2)) \
  "IF-T" & (state(e_1, sigma) bstep "true" quad state(e_2, sigma) bstep v_2) /
           (state("if" e_1 "then" e_2 "else" e_3, sigma) bstep v_2) \
  "IF-F" & (state(e_1, sigma) bstep "false" quad state(e_3, sigma) bstep v_3) /
           (state("if" e_1 "then" e_2 "else" e_3, sigma) bstep v_3) \
   "LET" & (state(e_1, sigma) bstep v_1 quad
           state(e_2, sigma[x mapto v_1]) bstep v_2)
           / (state("let" x=e_1 "in" e_2, sigma) bstep v_2)
$

== MiniML

(Only additional rules shown.)

==== Dynamic Scoping

$
  "FUN" & ()
          /
          (state("fun" x "->" e, sigma) bstep ("fun" x "->" e)) \
  "APP" & (state(e_1, sigma) bstep ("fun" x "->" e'_1)
          quad state(e_2, sigma) bstep v_2
          quad state(e'_1, text(fill: #red, sigma)[x mapto v_2]) bstep v
          ) /
          (state(e_1 e_2, text(fill: #red, sigma)) bstep v)
$

==== Lexical Scoping

$
  "CLOSURE" & ()
              /
              (state("fun" x "->" e, sigma)
              bstep
              [|"fun" x "->" e, sigma|]) \
      "APP" & (state(e_1, sigma) bstep [| "fun" x "->" e'_1, text(fill: #red, sigma') |]
              quad state(e_2, sigma) bstep v_2
              quad state(e'_1, text(fill: #red, sigma')[x mapto v_2]) bstep v
              ) /
              (state(e_1 e_2, sigma) bstep v)
$

/*

#pagebreak()


= Proof Tree

== General form

$
  "R1" dfrac(
    p_1 quad
    "R2" dfrac(p_1 quad p_2 quad ..., c_1) wide
    "R3" dfrac(p_1 quad "R4" dfrac(p_1 quad p_2, c_2), c_3),
    c_4
  )
$

== Examples

Evaluate: `(1+2)*3`

$
  "BOP"
  dfrac(
    "BOP" dfrac(
      "INT" dfrac(, 1 bstep 1) quad"INT" dfrac(, 2 bstep 2),
      1+2 bstep 3
    )
    quad
    "INT" dfrac(, 3 bstep 3),
    (1+2)*3 -> 9
  )
$

Evaluate: `if 1 < 2 then 10 else 20`

Evaluate: `let x=5 in x*8`

*/
