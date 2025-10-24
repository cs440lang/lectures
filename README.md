# CS 440 Lecture Repository

This repository contains lecture slides (in Markdown) and source code used for
the OCaml-based portions of CS 440: Programming Languages.

The *main* branch contains the "final" version of source files (with fleshed-out
functions, types, etc.), while the *demo* branch contains the "starter" versions
(those I'll start out with during lecture demos). If you want to code along
during lecture, I recommend creating a branch off of *demo* to do so.

To load all the lecture source files as modules in the toplevel, do:

```bash
dune build
dune utop
```

At the toplevel you can now do:

```ocaml
# L01_basics.class_name;;
- : string = "CS 440: Programming Languages"
```

or

```ocaml
# open L01_basics;;
# class_name;;
- : string = "CS 440: Programming Languages"
```

-- Michael Lee <lee@iit.edu>
