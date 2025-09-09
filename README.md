# CS 440 Lecture Repository

This repository contains lecture slides (in Markdown) and source code used for
the OCaml-based portions of CS 440: Programming Languages.

I will likely be making changes to these files throughout the semester, so
please be sure to pull the most recent changes before attending lecture. To
avoid merge issues, I recommend you create a separate branch for your own
additions and modifications so that you can always pull my changes into a
pristine local branch.

To load all the lecture source files as modules in the toplevel, do:

```bash
dune build
dune utop src
```

Now you can do:

```ocaml
# L01_intro.x;;
```

-- Michael Lee <lee@iit.edu>
