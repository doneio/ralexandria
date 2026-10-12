(cl:defpackage #:ralexandria.prog.renaming-test
  (:use #:common-lisp)
  (:export #:my-with-accessors
           #:*my-special-variable*
           #:example1-test
           )
  (:local-nicknames (#:p #:ralexandria.prog.renaming)
                    (#:p-impl #:ralexandria.prog.renaming-impl)))
