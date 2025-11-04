#show heading: set block(below: 1em)

#let bop = sym.plus.o
#let mapto = sym.arrow.r.bar
#let tstile = sym.tack.r
#let rtstile = sym.tack.l

#let nonumeq = math.equation.with(block: true, numbering: none)
#let dm(x) = box[#nonumeq[#x]]
#let dfrac(x, y) = math.frac(dm(x), dm(y))

= Static Semantics (Typing Rules)

== Basic Notation

We use $tau$ for meta-variables ranging over arbitrary types, $alpha$, $beta$,
$gamma$ for type variables occuring in language-level type expressions, and $pi$
for type schemes. $Gamma$ denotes a typing context.

#grid(
  columns: 2,
  gutter: 1em,
  align: (right, left),

  [$Gamma tstile e : tau$], [Under $Gamma$, $e$ has type $tau$],

  [$tstile e : tau$], [$e$ has type $tau$ in the empty context],

  [$Gamma(x)$], [Look up the type or type scheme assigned to $x$ in $Gamma$],

  [$Gamma(x) = tau$], [In $Gamma$, $x$ is assigned type $tau$],

  [$Gamma(x) = pi$], [In $Gamma$, $x$ is assigned type scheme $pi$],

  [$Gamma[x mapto tau\/pi]$],
  [Extend $Gamma$ by assigning $x$ the type $tau$ or type scheme $pi$],

  [$Gamma tstile e : tau rtstile C$],
  [Under $Gamma$, $e$ is inferred to have type $tau$ if constraint set $C$ is satisfiable],

  [fresh($alpha$)],
  [Generate a _fresh_ type variable $alpha$ -- i.e., one that is not
    used elsewhere],

  [free($tau$)], [Compute the set of free type variables found in $tau$],
)

#v(1em)

== Type Checking

In our type-checked language, unlike SimPL and MiniML, functions declare
their parameter types explicitly. E.g., `fun var : type -> body`. This is
reflected in the "FUN" rule, below.

$
    "INT" & () / (Gamma tstile i in ZZ : "int") \
          \
   "BOOL" & () / (Gamma tstile b in {"true", "false"} : "bool") \
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

The rules below are for monomorphic type inference of MiniML.

$
    "INT" & () / (Gamma tstile i in ZZ : "int" rtstile {}) \
          \
   "BOOL" & () / (Gamma tstile b in {"true", "false"} : "bool" rtstile {}) \
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
     "IF" & ("fresh"(alpha)
            quad Gamma tstile e_1 : tau_1 rtstile C_1
            quad Gamma tstile e_2 : tau_2 rtstile C_2
            quad Gamma tstile e_3 : tau_3 rtstile C_3)
            / (Gamma tstile "if" e_1 "then" e_2 "else" e_3 : alpha
            rtstile C_1 union C_2 union C_3
            union { tau_1 = "bool", alpha=tau_2, alpha=tau_3}) \
          \
    "LET" & (
            Gamma tstile e_1 : tau_1 rtstile C_1
            quad
            Gamma[x mapto tau_1] tstile e_2 : tau_2 rtstile C_2
            )/(
            Gamma tstile "let" x = e_1 "in" e_2 : tau_2 rtstile C_1 union C_2
            ) \
          \
    "FUN" & ("fresh"(alpha)
            quad Gamma[x mapto alpha] tstile e : tau rtstile C)
            / (Gamma tstile "fun" x "->" e : alpha -> tau
            rtstile C) \
          \
    "APP" & ("fresh"(alpha)
            quad Gamma tstile e_1 : tau_1 rtstile C_1
            quad Gamma tstile e_2 : tau_2 rtstile C_2)
            / (Gamma tstile e_1 e_2 : alpha rtstile C_1 union C_2
            union { tau_1 = tau_2 -> alpha})
$

#v(1em)

The following rules replace the corresponding ones above for polymorphic type
inference. Note that for polymorphic type inference, $Gamma$ maps a variable to
a type scheme $pi$ (instead of a monotype $tau$).

$
  "VAR" & (
          Gamma(x) = pi
          quad tau = bold("Instantiate")(pi)
          )/(
          Gamma tstile x : tau rtstile {}
          ) \
        & "where" bold("Instantiate")(forall alpha_1, ..., alpha_n.tau)
          = ["fresh"(beta_i) \/ alpha_i] tau \
        \
  "LET" & (
          Gamma tstile e_1 : tau_1 rtstile C_1
          quad pi_1 = bold("Generalize")(Gamma, tau_1)
          quad Gamma[x mapto pi_1] tstile e_2 : tau_2 rtstile C_2
          ) / (
          Gamma tstile "let" x = e_1 "in" e_2 : tau_2 rtstile C_1 union C_2
          ) \
        & "where" bold("Generalize")(Gamma, tau) =
          forall alpha_1, ..., alpha_n. tau
          and alpha_i in ("free"(tau) - "free"(Gamma)) \
        \
$
