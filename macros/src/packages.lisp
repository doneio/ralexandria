(cl:in-package #:common-lisp)

(defpackage #:ralexandria.macros
  (:export #:with-gensyms
           #:once-only
           #:WHILE
           #:UNTIL))

(defpackage #:ralexandria.macros-impl
  (:use #:common-lisp)
  (:local-nicknames (#:macros #:ralexandria.macros)))

(in-package #:ralexandria.macros)

