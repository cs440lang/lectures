#lang racket

#|-----------------------------------------------------------------------------
;; Desugaring (Syntax Transformation)

Our language now includes arithmetic expressions, variables, and closures.
We can (and will!) grow the language, but how should we go about building
support for new language constructs?

We could modify the interpreter to recognize and implement each new construct,
but this might not scale well. Our interpreter could grow complex and hard to
maintain, and our language might become bloated and messy.

Alternatively, we could specify a small "core" language which will provide a
minimal set of features needed to implement all other language constructs.

The parser would accept programs written in the full language (aka the "input
language") and create a syntax tree, as before. Before sending the tree to the
interpreter, however, we would apply one or more "desugaring" passes to the
syntax tree to transform all its nodes into those of the core language.

The final desugared form of the syntax tree -- now serving as a flexible
internal representation (IR) of our program -- can be directly evaluated.

Here is the process described above:

    Program (input language) => Parser => Syntax Tree / IR (input language)

    IR (input language) => Desugaring Pass(es) ... => IR (core language)

    IR (core language) => Interpreter / Eval

---

As an example of desugaring, we will add support for lambdas and function
applications that accept > 1 params/args. This will *not* require any
modifications to our interpreter, as we can rewrite such expressions using
the existing core language.

e.g., support for lambda and function application with > 1 params/args

    (lambda (x y z ...)     can be written as     (lambda (x)
      body)                                         (lambda (y)
                                                      (lambda (z)
                                                        ...
                                                          body)))

   if we ensure that all function applications of the form (f x y z ...)
   are rewritten as ((((f x) y) z) ...)
-----------------------------------------------------------------------------|#

;; Some test cases
(define p1 '(lambda (x y z) (* x (+ y z))))

(define p2 '(f x y z))

(define p3 '((lambda (x y z) (* x (+ y z))) 2 3 4))


;; integer value
(struct int-exp (val) #:transparent)

;; arithmetic expression
(struct arith-exp (op lhs rhs) #:transparent)

;; variable
(struct var-exp (id) #:transparent)

;; let expression
(struct let-exp (ids vals body) #:transparent)

;; lambda expression
(struct lambda-exp (id body) #:transparent)

;; function application
(struct app-exp (fn arg) #:transparent)


;; Parser
(define (parse sexp)
  (match sexp
    ;; integer literal
    [(? integer?)
     (int-exp sexp)]

    ;; arithmetic expression
    [(list '+ lhs rhs)
     (arith-exp "PLUS" (parse lhs) (parse rhs))]
    [(list '* lhs rhs)
     (arith-exp "TIMES" (parse lhs) (parse rhs))]

    ;; identifier (variable)
    [(? symbol?)
     (var-exp sexp)]

    ;; let expressions
    [(list 'let (list (list id val) ...) body)
     (let-exp (map parse id) (map parse val) (parse body))]

    ;; lambda expression -- modified for > 1 params
    [(list 'lambda (list ids ...) body)
     (lambda-exp ids (parse body))]

    ;; function application -- modified for > 1 args
    [(list f args ...)
     (app-exp (parse f) (map parse args))]

    ;; basic error handling
    [_ (error (format "Can't parse: ~a" sexp))]))


;; Desugar-er -- i.e., syntax transformer
(define (desugar exp)
  (match exp
    ((arith-exp op lhs rhs)
     (arith-exp op (desugar lhs) (desugar rhs)))

    ((let-exp ids vals body)
     (let-exp ids (map desugar vals) (desugar body)))

    ;; try:
    ; (foldr (lambda (id body) `(lambda (,id) ,body))
    ;        'body
    ;        '(x y z))
    ((lambda-exp ids body)
     (foldr (lambda (id body) (lambda-exp id body))
            (desugar body)
            ids))

    ;; try:
    ; (foldl (lambda (id fn) `(,fn ,id))
    ;        'fn
    ;        '(a b c))
    ((app-exp fn args)
     (foldl (lambda (id fn) (app-exp fn id))
            (desugar fn)
            (map desugar args)))

    (_ exp)))


;; function value + closure
(struct closure (id body env) #:transparent)


;; Interpreter
(define (eval expr)
  (let eval-env ([expr expr]
                 [env '()])
    (match expr
      ;; int literal
      [(int-exp val) val]

      ;; arithmetic expression
      [(arith-exp "PLUS" lhs rhs)
       (+ (eval-env lhs env) (eval-env rhs env))]
      [(arith-exp "TIMES" lhs rhs)
       (* (eval-env lhs env) (eval-env rhs env))]

      ;; variable binding
      [(var-exp id)
       (let ([pair (assoc id env)])
         (if pair (cdr pair) (error (format "~a not bound!" id))))]

      ;; let expression
      [(let-exp (list (var-exp id) ...) (list val ...) body)
       (let ([vars (map cons id
                        (map (lambda (v) (eval-env v env)) val))])
         (eval-env body (append vars env)))]

      ;; lambda expression
      [(lambda-exp id body)
       (closure id body env)]

      ;; function application
      [(app-exp f arg)
       (match-let ([(closure id body clenv) (eval-env f env)]
                   [arg-val (eval-env arg env)])
         (eval-env body (cons (cons id arg-val) clenv)))]

      ;; basic error handling
      [_ (error (format "Can't evaluate: ~a" expr))])))


;; REPL
(define (repl)
  (let ([stx (desugar (parse (read)))]) ; added desugaring step
    (when stx
      (println (eval stx))
      (repl))))
