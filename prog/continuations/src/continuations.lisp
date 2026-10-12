(in-package #:ralexandria.prog.continuations-impl)

(defvar continuations:*actual-cont* #'values)

(define-symbol-macro continuations:*cont*
  continuations:*actual-cont*)

(defun prepend= (symbol)
  (concatenate 'string
               "=" (symbol-name symbol)))

(defun intern= (symbol)
  (intern (prepend= symbol)
          (symbol-package symbol)))

(defmacro continuations:=lambda (params &body body)
  "A lambda with the continuation as its first parameter. Inside the body,
*cont* names that parameter (via symbol-macrolet), so =values feeds it."
  ;; Paul Graham used a top-level setq
  ;; (thus not conforming to the ANSI)
  ;; for continuations:*cont*
  ;; otherwise the continuations mechanism fails.
  (let ((gcont (gensym "CONT")))
    ;; The translator of the book into Chinese tried to fix it but his fix violates:
    ;; ANSI 3.1.2.1.1 "If a symbol is already defined as a global symbol macro, it cannot be bound as a lexical variable."
    ;; So we bind a lexical variable then shadow the global symbol macro using symbol-macrolet, this is conforming.
    ;; ANSI CLHS Section 3.1.2.1.1 (Shadowing) "The binding of a symbol macro can be shadowed by symbol-macrolet."
    `(lambda (,gcont ,@params) 
       (symbol-macrolet ((continuations:*cont* ,gcont))
         ,@body))))

(defmacro continuations:=defun (name params &body body)
  "Define NAME as a macro that threads the current *cont* into =NAME, plus the
underlying =NAME function taking the continuation as its first parameter."
  (let ((=name (intern= name))
        (gcont (gensym "CONT")))
    `(progn
       (defmacro ,name ,params
         `(,',=name continuations:*cont* ,,@params))
       (defun ,=name (,gcont ,@params)
         (symbol-macrolet ((continuations:*cont* ,gcont))
           ,@body)))))

(defmacro continuations:=labels (fns &body body)
  "Like =defun but for mutual/local recursion in one form. A MACROLET wraps the
LABELS so references to NAME expand to (=NAME *cont* ...) (threading the current
continuation); LABELS (not FLET) so the =NAME functions see their siblings and
recurse. Each =NAME function takes the continuation as its first parameter and
binds *cont* to it via symbol-macrolet."
  (let* ((names (mapcar #'car fns))
         (params (mapcar #'second fns))
         (bodies (mapcar #'cddr fns))
         (fnames (mapcar #'intern= names))
         (gcont (gensym "CONT")))
    `(macrolet (,@(mapcar (lambda (name fname lambda-list)
                            `(,name ,lambda-list
                               `(,',fname continuations:*cont* ,,@lambda-list)))
                          names fnames params))
       (labels (,@(mapcar (lambda (fname lambda-list body)
                            `(,fname (,gcont ,@lambda-list)
                               (symbol-macrolet ((continuations:*cont* ,gcont))
                                 ,@body)))
                          fnames params bodies))
         ,@body))))

(defmacro continuations:=bind (params expr &body body)
  "Run EXPR with *cont* bound to a continuation that, when invoked with values,
binds them to PARMS and runs BODY. The continuation lives in a lexical gensym,
so closures created in BODY capture it and can be resumed after =bind returns.

The lambda is assigned with setf INSIDE the let body (not as the let init
form): a let's init form is in the outer scope, so the variable being bound is
NOT in lexical scope within its own init form — a self-referencing init form
would capture the global gensym (unbound), not the let var. setf after the
binding is the standard letrec pattern, and keeps the continuation as a
passable function VALUE (not a labels-only function name), so =funcall/=apply
work inside a =bind too."
  (let ((gcont (gensym "CONT")))
    `(let ((,gcont nil))
       (setf ,gcont (lambda ,params
                      (symbol-macrolet ((continuations:*cont* ,gcont))
                        ,@body)))
       (symbol-macrolet ((continuations:*cont* ,gcont))
         ,expr))))

(defmacro continuations:=values (&rest retvals)
  "Feed RETVALS to the current continuation *cont*."
  `(funcall continuations:*cont* ,@retvals))

(defmacro continuations:=funcall (fn &rest args)
  "Call FN with the current continuation as its first argument, then ARGS.
FN must take the continuation first (e.g. an =lambda or =defun'd =NAME)."
  `(funcall ,fn continuations:*cont* ,@args))

(defmacro continuations:=apply (fn &rest args)
  "Like cl:apply for continuation-taking functions: the last of ARGS is a list."
  `(apply ,fn continuations:*cont* ,@args))
