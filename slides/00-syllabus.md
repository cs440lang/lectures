# Course Syllabus

## Overview

This class serves as an introduction to the rich field of Programming Language
Theory (PLT).

Programming languages are our primary tools for expressing computational ideas,
yet most programmers use them without understanding their underlying principles.
This course demystifies programming languages by teaching you to think like a
language designer. You'll learn to recognize patterns across languages, evaluate
language features critically, and understand why languages work the way they do.

While most of your undergraduate coursework has focused on imperative and
object-oriented programming, functional programming offers a different -- and
often clearer -- lens for understanding fundamental concepts in computer
science. Functional languages make explicit many ideas that remain hidden in
imperative languages: evaluation strategies, scope and binding, higher-order
abstractions, and type systems. By starting with the lambda calculus and
building up through OCaml, we establish a rigorous mathematical foundation that
applies broadly across all programming paradigms.

Moreover, functional programming techniques are increasingly important in
industry. Ideas from functional languages -- immutability, first-class
functions, pattern matching, type inference -- now appear in mainstream
languages like Python, JavaScript, Rust, and even Java. Understanding these
concepts at their source will make you a more versatile and thoughtful
programmer, regardless of which language(s) you use professionally.

In this course, we won't just study programming languages. We'll build them.
You'll implement multiple interpreters, gaining deep insight into how languages
work by constructing them from the ground up.

## Topics

The overarching topics we will cover this semester include:

- The Lambda Calculus (~1 week)
- Functional Programming with OCaml (~4 weeks)
- Interpreters and Compilers (~1 week)
- Operational Semantics and Evaluation (~2 weeks)
- Type Checking and Inference (~3 weeks)
- Axiomatic Semantics and Hoare Logic (~2 weeks)

## Learning Outcomes

After completing this class, students should be able to:

- *Reason with functional programming abstractions*: Apply pattern matching,
  recursion, higher-order functions, closures, and algebraic data types to solve
  problems elegantly and correctly
- *Implement language processors*: Design and implement lexers, parsers, and
  interpreters for programming languages using tools like `ocamllex` and
  `menhir`
- *Formalize language semantics*: Use operational semantics to precisely specify
  how programs evaluate, and apply these specifications to reason about program
  behavior
- *Design and implement type systems*: Explain the theory behind type checking
  and type inference, implement type checkers for languages with increasingly
  complex type systems (including polymorphic type inference), and understand
  the Hindley-Milner type system
- *Verify program correctness*: Apply axiomatic semantics and Hoare logic to
  formally reason about program correctness and prove properties of programs
- *Evaluate language design*: Critically analyze programming language features
  and design decisions, understanding their trade-offs and implications for
  expressiveness, safety, and performance

## Faculty & Staff

Professor: Michael Lee

- Email: <lee@iit.edu>
- Office hours: TBA

TA: TBA

## Grading

Grades in the class are broken down as follows:

- 50%: Assignments
- 25%: Midterm Exam
- 25%: Final Exam

And here's the final grade scale:

- A: ≥ 90%
- B: 80-89%
- C: 70-79%
- D: 60-69%
- E: < 60%

## Assignments

Assignments consist of *machine problems* (i.e., programming exercises), and
written *problem sets*. Machine problem solutions will be submitted via shared,
private repositories on GitHub, and written assignment submissions must be
neatly written or typed up and submitted via Canvas. Assignments have varying
point values, and will be weighted proportionally.

### Late Policy

In general, assignments will not be accepted late for any credit. I understand,
however, that circumstances may arise in life, school, and work that get in the
way of a timely submission. If you have a valid reason (i.e., not just
procrastination or time mismanagement) for needing an extra day or two, please
get in touch with me *before* an assignment is due, and we can discuss the
possibility of an extension.

## Academic Honesty

All assignment submissions (including code and written solutions) should be
entirely your own, excluding provided scaffolding. If we find evidence of
plagiarism, the first offense will result in the plagiarized work receiving a 0
(for all parties involved). A second offense will be reported to the Designated
Dean of Academic Discipline, and may result in expulsion from the class.

Please see the Illinois Tech Code of Academic Honesty for the official policies
and procedures governing academic integrity violations.

## On AI Use

Generative AI systems (like ChatGPT), if used correctly, can serve as powerful
tools for learning and idea refinement. In this course, you can use generative
AI systems to learn about concepts iteratively through a conversation (much like
you would have a conversation with a peer, TA or an instructor). However, you
cannot ask these systems to directly give you answers or write code for you. One
reason for this is because the answers that the system generates can be
inaccurate (no matter how confident the system might sound). But more
importantly, I believe the intellectual growth you can get from working through
a difficult problem and discovering the answer for yourself cannot be replicated
by just reading a pre-generated answer. Here are some concrete rules that
exemplify this (but are not intended to be comprehensive):

Do NOT:

- Give the model a problem description and ask it to sketch an algorithm for you
  or write pseudo code.
- Give the model the homework description and ask it to organize the code for
  you.
- Give the model a function description and ask it to generate code for you.
- Have your conversation with the model and your assignment open at the same
  time. Instead, use your conversation with the AI as a learning experience,
  then close the interaction down, open your assignment, and let your assignment
  reflect your revised knowledge.

Using the AI system in ways as described above will count as plagiarism even if
you cite the AI system as a source.

You CAN:

- Ask clarification questions about the fundamentals of programming (e.g., "When
  should I use a higher order function?")
- Ask for conceptual clarifications (e.g., "What is the difference between a
  compiler and interpreter?")
- Try to work through the logic of something you don’t understand (e.g., "Can
  you walk me through the type inference for `fun x -> x`?")
- Give a problem description and your proposed algorithm and "talk" through the
  potential fallacies.

## Disability Resources

Reasonable accommodations will be made for students with documented
disabilities. In order to receive accommodations, students must obtain a letter
of accommodation from the Center for Disability Resources. The Center for
Disability Resources is located in the Life Sciences Building, room 218,
312-567-5744 or disabilities@iit.edu.

## Sexual Harassment and Discrimination Information

Illinois Tech prohibits all sexual harassment, sexual misconduct, and gender
discrimination by any member of our community. This includes harassment among
students, staff, or faculty. Sexual harassment of a student by a faculty member
or sexual harassment of an employee by a supervisor is particularly serious.
Such conduct may easily create an intimidating, hostile, or offensive
environment.

Illinois Tech encourages anyone experiencing sexual harassment or sexual
misconduct to speak with the Office of Title IX Compliance for information on
support options and the resolution process.

You can report sexual harassment electronically at
https://iit.edu/incidentreport, which may be completed anonymously. You may
additionally report by contacting the Title IX Coordinator, Virginia Foster at
foster@iit.edu.

For confidential support, you may reach Illinois Tech’s Confidential Advisor at
(773) 907-1062. You can also contact a licensed practitioner in Illinois Tech’s
Student Health and Wellness Center at student.health@iit.edu or 312-567-7550

For a comprehensive list of resources regarding counseling services, medical
assistance, legal assistance and visa and immigration services, you can visit
the Office of Title IX Compliance website at
https://www.iit.edu/title-ix/resources.

## On Changes to the Syllabus

This syllabus, like our course, should be seen as an evolving experience, and
from time to time changes might become necessary. I reserve the right to modify
this syllabus, with the stipulation that any changes will be communicated to the
entire class clearly and in writing.
