# CS 440: Programming Languages

## Lecture Repository

This repository contains source code used in class demos.

The *main* branch contains the "final" version of source files (with fleshed out functions, types, etc.), while the *demo* branch contains the "starter" versions (those I'll start out with during lecture demos). If you want to code along during lecture, I recommend creating a branch off of *demo* to do so.

To load all the lecture source files as modules in the toplevel, do:

```bash
dune build
dune utop
```

At the toplevel you can now do:

```ocaml
# L03_ocamlintro.class_name;;
- : string = "CS 440: Programming Languages"
```

or

```ocaml
# L08_lc.Eval.repl ();;
> (\x.x) y
y
```

-- Michael Lee <lee@iit.edu>
