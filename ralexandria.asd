(in-package #:asdf-user)

(defsystem :ralexandria
  :name ""
  :depends-on #1=(#:ralexandria.clos
                  #:ralexandria.clos.print-method-for
                  #:ralexandria.clos.tracked-class
                  #:ralexandria.macros
                  #:ralexandria.macros.with-accessors
                  #:ralexandria.prog
                  #:ralexandria.prog.proj
                  #:ralexandria.prog.renaming
                  #:ralexandria.prog.continuations
                  #:ralexandria.reader.multiline-string
                  #:ralexandria.sequences
                  #:ralexandria.strings
                  #:ralexandria.strings.regex)
  :components ()
  :in-order-to ((test-op
                 #.(cons 'test-op '#1#))))
