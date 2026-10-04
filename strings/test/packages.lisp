(cl:defpackage #:ralexandria.strings-test
  (:use #:common-lisp)
  (:local-nicknames (#:strings #:ralexandria.strings)
                    (#:strings-impl #:ralexandria.strings-impl))
  (:export #:do-tests))
