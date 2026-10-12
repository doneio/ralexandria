(cl:defpackage #:ralexandria.prog.proj-test
  (:use #:common-lisp)
  (:local-nicknames (#:proj #:ralexandria.prog.proj)
                    (#:proj-impl #:ralexandria.prog.proj-impl)
                    (#:strings #:ralexandria.strings))
  (:export #:do-tests))
