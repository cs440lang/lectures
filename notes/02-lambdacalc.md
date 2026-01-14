# The Lambda (λ) Calculus

## Agenda

- History & Motivation
- Syntax & Semantics
- Normalization & Evaluation
- Data Representation
- Recursion

## A Bit of History

In 1928, Hilbert and Ackermann posed the *Entscheidungsproblem* ("decision problem") which essentially asks:

- Is there a mechanical procedure (algorithm) that can decide (compute) the validity of any statement in first-order logic?

- Answering this requires clear notions of *algorithm* and *computation*

### Models of Computation

By 1936, Alonzo Church proposed the *λ-calculus* (aka "λ") and Alan Turing proposed the *Turing machine* as independent models of computation

- λ being inherently *stateless* and functional

- Turing machines being inherently *stateful*

### Church-Turing Thesis

Both models were used to *deny* the entscheidungsproblem

- Turing demonstrated *undecidability* via the halting problem

- Church showed that *no computable function* can decide whether two λ-expressions are equivalent

Both models showed that *no universal decision procedure* can exist

- Not only did the models agree, Church also showed that the models are *computationally equivalent*

## What is the λ-Calculus?

- A *minimal formal system* for describing computation

- An extremely simple *functional programming language*

  - Everything is built from *functions* and *function application*

- Despite its simplicity, it is *Turing complete*

  - Numbers, data structures, control flow can all be encoded in it

### Why study it?

- It distills the *essential concepts* of all functional languages

  - E.g., functions, variables, scope, substitution, and evaluation

- It provides the *theoretical basis* for much of PL: type systems, optimizations, formal semantics, proofs

- Studying it builds intuition for *all programming languages*!

## Syntax & Semantics

### Grammar

In Backus-Naur Form (BNF):

```bnf
<expr> ::=  <var> | <abs> | <app> | ( <expr> )
<var>  ::=  [a-z]+
<abs>  ::=  λ<var>.<expr>
<app>  ::=  <expr> <expr>
```

Examples:

- Variables: `w`, `x`, `y`, `f`, `g`, `h`

- Abstractions: `λx.x`, `λx.λy.x`, `λf.λx.f x`

- Applications: `f x`, `g (f x)`, `(λf.λx.f x) (λy.y) w`

### What is an "Abstraction"?

Consider the concrete arithmetic expression `(3 + 5) * 2`

- we may want to generalize this for *any value* `x` in place of `3`

- we *abstract* over the `3` with variable `x` by writing `λx.((x + 5) * 2)`

  - we can now *apply* this λ-abstraction, substituting an argument in place of `x` in the body

#### Abstractions = Anonymous Functions

The abstraction `λx.((x + 5) * 2)` introduces a variable named `x`, but *not* a name for the abstraction itself!

- Unlike most languages, there's no "definition" syntax to give names to functions

- How can we bind a name to an abstraction?

  - Consider `(λf.f 3) (λx.((x + 5) * 2))`

#### Abstractions all the way down ...

λ doesn't feature arithmetic operators, or even integers

- The *only primitive type* in λ is the abstraction!

So we cannot directly express `λx.((x + 5) * 2)` in λ

- How do we model operations on integers and other data?

  - As abstractions! (more on this later)

### Associativity & Precedence

#### 1. Abstractions are *right-associative*

I.e., if there are multiple abstractions in a row, the *rightmost* one is grouped with its body first.

- E.g., `λx.λy.x` = `λx.(λy.x)`

- E.g., `λx.λy.λz.x` = `λx.(λy.(λz.x))`

#### 2. Application is *left-associative*

I.e., in a series of (unparenthesized) function applications, the *leftmost* one is carried out first

- E.g., `f x y z` = `(((f x) y) z)`

We can use parentheses to explicitly control application order:

- E.g., `f x (y z)` = `((f x) (y z))`

- E.g., `f (x y) z` = `((f (x y)) z)`

#### 3. Application has *higher precedence* than abstraction

We say that application "binds tighter"

- E.g., `λx.x λz.x z` = `λx.(x (λz.(x z)))`

  - `λx.x λz.x z` ≠ <span style="color:red">(λx.x) (λz.x) z</span>

As a consequence of all the rules, the "body" of an abstraction *extends as far right* as possible

### Abstract Syntax Trees (ASTs)

ASTs help us visualize the relationships between terms in a λ-expression

Draw the ASTs for:

- `λx.x`
- `f x y`
- `λx.f x`
- `x (λy.y) z`
- `λw.(λx.x z) (λy.y z)`

### Bound and Free Variables

When a variable is found in the body of an abstraction that names it, the variable is *bound*. Otherwise, it is *free*.

E.g., `x` is bound in:

- `λx.x`
- `λx.f x`
- `λx.λy.x`

E.g., (some) `x` is free in:

- `λy.x`
- `x λx.f x`
- `(λx.y) (λy.x)`

In an AST, a variable is free if we can't find an ancestor λ that names it

### Variable Scope

The scope of a variable introduced by a λ-abstraction extends throughout its entire body

- Unless a nested λ-abstraction binds a variable *with the same name*

  - Inner bindings "shadow" outer ones

  - A variable is bound by its *closest ancestral binding*

### β-reduction

When a λ-expression contains an abstraction that is applied to an argument, we can *reduce* the expression by substituting the argument for the bound variable in the abstraction's body. We call this step a *β-reduction*.

More succinctly:

```typst +render +width:60%
$
(lambda x . M) N -->_beta [N\/x]M
$
```

- `[N/x] M` means "substitute `N` for `x` in `M`"

#### Practice β-reductions

Carry out as many β-reductions as possible on the following expressions:

- `(λx.x) y`

- `(λx.λx.x) y`

- `(λx.x z) (λy.y)`

- `(λx.λy.y x) a b`

- `(λx.λy.y x) y`

### Variable Capture

There is a potential for *variable capture* when a β-reduction would cause a previously free variable to fall into the scope of a binding abstraction.

- e.g., `(λx.λy.y x) y` -β-> <span style="color:red">λy.y y</span>

This β-reduction would change the meaning of the free `y`!

- It is prohibited

### α-conversion

We prevent variable capture by *renaming bound variables* (aka *α-conversion*)

- This is a semantics-preserving operation (if we're careful!)

- Two λ-expressions are *α-equivalent* if one can be converted into the other via α-conversion.

#### Practice α-conversions

Produce different but α-equivalent expressions for each expression below by α-converting *all* their bound variables.

- `λa.a`

- `λb.λb.b b`

- `λw.x w λx.w x`

- `(λx.λy.y x) y`

#### More Practice β-reductions

Carry out as many β-reductions as possible on the following expressions, performing α-conversions as needed:

- `(λx.λy.y x) y`

- `(λx.λz.z x) (λy.z) (λa.a a)`

### η-reduction

We can directly simplify abstractions of the form `λx.M x`, where `M` is an arbitrary expression that *does not contain a free `x`*

```typst +render +width:40%
$
lambda x . M x -->_eta M
$
```

This captures *extensional equality*: functions are equal if they behave the same on all inputs. `M` and `λx.M x` behave identically, so they're equivalent.

Example: `λy.λx.y x` -η-> `λy.y`

- Consider: `(λy.λx.y x) a b` -β-> ... ?

- Intuition: an η-reduction is like *anticipating a future β-reduction*

## Normalization & Evaluation

### Normal Form

A λ-expression/sub-expression that can be β- or η-reduced is called a *redex*.

A λ-expression with *no redexes* is in *normal form*.

Questions to consider:

- When evaluating a λ program, should we always shoot for normal form?

- Is it always possible to normalize a given λ-expression?

#### Weak Head Normal Form (WHNF)

When evaluating a λ program, should we always shoot for normal form?

- In practice, no.

  - Consider: `λx.(λw.x w) x`. Reducing the body would be like evaluating a function prematurely; most PLs don't do this.

- It is common to stop evaluating once the expression is rooted at a λ-abstraction. We call this *Weak Head Normal Form*.

#### Divergence

Is it always possible to reduce a given λ-expression to normal form?

- No! λ-expressions may *diverge* -- i.e., reduce infinitely.

  - Consider: `(λx.x x) (λx.x x)` (known as the Ω-combinator)

### Evaluation Strategy

When evaluating a λ-expression, we may encounter multiple simultaneous redexes. *In what order* do we reduce them?

- E.g., `(λx.(λy.y) x) ((λw.w)(λz.z))` (can you spot all the redexes?)

- This question is central to the behavior of a program and the implementation of an evaluator!

Two standard strategies:

- Applicative-order evaluation

- Normal-order evaluation

#### Applicative-Order Evaluation

If the argument for a λ-abstraction can be reduced, reduce it before applying the abstraction. If there are multiple layers of application, reduce the *innermost first*.

We can write this as a *rule of inference*:

```typst +render +width:50%
$
(N -->_beta N')
/((lambda x.M)N -->_beta (lambda x.M)N')
$
```

- This strategy is also called *call-by-value* or *eager* evaluation

#### Normal-Order Evaluation

Apply λ-abstractions before reducing any of their arguments. If there are multiple layers of application, reduce the *outermost first*.

```typst +render +width:50%
$
(lambda x.M)N -->_beta [N\/x]M
$
```

- This strategy is also called *call-by-name* or *lazy* evaluation

#### Practice Evaluation

Evaluate each of the following using both applicative and normal order strategies. Can you reach normal form?

- `(λx.λf.f x) (λz.z) ((λq.q) (λr.r))`

- `(λx.y) ((λx.x x) (λx.x x))`

### Pros/Cons of Evaluation Strategies

If a λ-expression has a normal form, normal-order evaluation *will* get us there while applicative-order reduction *may diverge*

- This is because normal-order reduction *ignores arguments that aren't used* (which may diverge)

  - Lazy evaluation has other benefits too: "infinite" data structures, "automatic" short-circuiting, etc.

But applicative-order evaluation guarantees a given argument *is only evaluated once*, and at a *predictable time* (before "passing" it)

- Most modern languages use this evaluation strategy

### Church-Rosser Theorem

Alonzo Church and John Rosser proved that, *regardless of the order* in which reductions are carried out, we can *reach the same result*.

Formally, they showed that if `M` -β-> `N1` and `M` -β-> `N2`, there exists some `X` such that `N1` -β-> `X` and `N2` -β-> `X`.

- This is known as the *diamond property* of β-reduction

An important corollary of this property is that *when a λ-expression has a normal form, it is unique*.

- I.e., regardless of what evaluation strategy we choose to implement, the final result of a program (if it terminates) won't differ!

## Data Representation

### Why Data Representation?

It's hard to believe the λ-calculus is Turing-complete / computationally universal if it doesn't contain even basic data types and operations.

- e.g., Booleans + logical operators, numbers + arithmetic operators

It turns out we can model all of these using just λ-abstractions!

### Boolean Operators & Values

Goal: define abstractions that model `TRUE`, `FALSE`, `IF`, `NOT`, `AND`, `OR`, where

```
IF  TRUE  X Y   = X
IF  FALSE X Y   = Y

NOT TRUE        = FALSE
NOT FALSE       = TRUE
```

```
AND TRUE  TRUE  = TRUE
AND TRUE  FALSE = FALSE
AND FALSE TRUE  = FALSE
AND FALSE FALSE = FALSE

OR  TRUE  TRUE  = TRUE
OR  TRUE  FALSE = TRUE
OR  FALSE TRUE  = TRUE
OR  FALSE FALSE = FALSE
```

Hint: Think of `TRUE` and `FALSE` as functions -- how many arguments would they each take, and which would each "pick"?

#### Boolean Operators & Values in λ

One possible implementation:

```
TRUE  = λx.λy.x
FALSE = λx.λy.y

IF    = λb.λm.λn.b m n

NOT   = λb.b FALSE TRUE = λb.b (λx.λy.y) (λx.λy.x)

AND   = λb1.λb2.b1 b2 FALSE

OR    = λb1.λb2.b1 TRUE b2
```

### Natural Numbers & Arithmetic

Goal: define abstractions that model `0`, `1`, `2` ..., `INC`, `ADD` where

```
INC 0    =  1
INC 1    =  2
...

ADD 0 0  =  0
ADD 0 1  =  1
ADD 1 1  =  2
...
```

Hint: a number `n` can be thought of as "do something `n` times". So `2` means "apply some function `f` twice to an argument `x`".

#### Church Numerals

One way of encoding natural numbers in λ:

```
0 = λf.λx.x
1 = λf.λx.f x
2 = λf.λx.f (f x)
...

INC = λn.λf.λx.f (n f x)

ADD = λm.λn.m INC n =  λm.λn.λf.λx.m f (n f x)
```

To encode integers, we could use a pair of natural numbers `A`, `B` where integer `N` = `A`-`B`.

## Recursion

### Why Recursion?

λ lacks any type of control structure, including loops -- e.g., `while`, `do-while`, `for`, etc., which are needed for *repetition*, *iteration*, and most every non-trivial *algorithm*.

These can all be replaced by recursion!

But λ also lacks *named functions*.

- How does a function call itself if it doesn't have a name?

### Give it a go ...

Implement the following function in λ:

```python
def f(n):
  return f(n+1)
```

Hint: use Church numerals!

#### Annotated Attempts

- Attempt 1: `λn.f (INC n)`

  - But where does `f` come from? Let's add it as an argument...

- Attempt 2: `λf.λn.f (INC n)`

  - But what value do we pass in as `f`? We are modeling recursion, so let's pass in a copy of the function itself ...

- Attempt 3: `(λf.λn.f (INC n)) (λf.λn.f (INC n))`

  - This is close, but calls to `f` now need itself as an argument ...

- Attempt 4: `(λf.λn.f f (INC n)) (λf.λn.f f (INC n))`

#### Test Evaluation

<span style="color:blue">(λf.λn.f f (INC n))</span>
<span style="color:green">(λf.λn.f f (INC n))</span> 0

(λn.<span style="color:blue">(λf.λn.f f (INC n))</span>
<span style="color:green">(λf.λn.f f (INC n))</span> (INC n)) 0

<span style="color:blue">(λf.λn.f f (INC n))</span>
<span style="color:green">(λf.λn.f f (INC n))</span> (INC 0)

<span style="color:blue">(λf.λn.f f (INC n))</span>
<span style="color:green">(λf.λn.f f (INC n))</span> 1

(λn.<span style="color:blue">(λf.λn.f f (INC n))</span>
<span style="color:green">(λf.λn.f f (INC n))</span> (INC n)) 1

<span style="color:blue">(λf.λn.f f (INC n))</span>
<span style="color:green">(λf.λn.f f (INC n))</span> (INC 1)

<span style="color:blue">(λf.λn.f f (INC n))</span>
<span style="color:green">(λf.λn.f f (INC n))</span> 2

...

### The Y-Combinator

We can extract this pattern into an abstraction that takes a function and makes it recursive.

- The *Y-combinator*: `Y` = `λf.`<span style="color:blue">(λx.f (x x))</span>
  <span style="color:green">(λx.f (x x))</span>

Example (`Y F`):

- `(λf.`<span style="color:blue">(λx.f (x x))</span>
  <span style="color:green">(λx.f (x x))</span>`) F`
- <span style="color:blue">(λx.F (x x))</span> <span style="color:green">(λx.F (x x))</span>

- `F (`<span style="color:blue">(λx.F (x x))</span>
  <span style="color:green">(λx.F (x x))</span>`)`

- `F (F (`<span style="color:blue">(λx.F (x x))</span>
  <span style="color:green">(λx.F (x x))</span>`))`
- ...

#### Termination?

`Y F` seems to expand forever: `F (F (... (F (Y F))))`. Can `Y F` terminate?

Yes! If `F` doesn't need its argument.

- Trivially, `F = λx.y`

- But this only works with normal-order (lazy) evaluation!

With applicative-order (eager) evaluation, `Y F` diverges.

- The *Z-combinator* adds an extra abstraction to delay recursion:

  - `Z` = `λf.(λx.f (λy.x x y)) (λx.f (λy.x x y))`

## Summary and Path Forward

### What We've Learned

**The λ-calculus is remarkably simple**

- Just three constructs: *variables*, *abstractions*, and *applications*
- Yet it's *Turing-complete*: powerful enough to express any computation

**The details matter**

- Syntax rules (associativity, precedence) determine structure
- Substitution requires care (α-conversion prevents variable capture)
- Evaluation strategy affects termination and efficiency

### Key Takeaways

**Everything is a function**

- Data (Booleans, numbers) encoded as abstractions
- Operations (logic, arithmetic) also encoded as abstractions
- Recursion achieved through self-application (`Y`, `Z` combinators)

**Evaluation strategies have real consequences**

- *Normal-order*: may terminate when applicative-order diverges
- *Applicative-order*: predictable, efficient, used by most languages
- *Church-Rosser*: final result is unique (when it exists)

### Why This Matters

λ-calculus provides the *theoretical foundation* for:

- *Functional programming languages* — Haskell, OCaml, Scheme, etc.
- *Type systems* — how we ensure program correctness
- *Compiler optimizations* — β-reduction, η-reduction, inlining
- *Formal semantics* — precise meanings for programs
- *Program verification* — proving properties about code

The concepts you've learned here — substitution, scope, evaluation order, and reduction — appear *everywhere* in PL theory and practice!

### From λ to OCaml

Next, we'll study **OCaml**, a functional language built on λ-calculus principles:

- *Functions as values*: first-class, anonymous, higher-order
- *Currying*: multi-argument functions as nested single-argument ones
- *Substitution & scope*: the same concepts, with clearer syntax
- *Evaluation strategies*: OCaml uses eager evaluation

OCaml adds practical features: data structures, pattern matching, modules, and a *type system* that catches errors before runtime.
