(defpackage #:ralexandria.prog.proj
  (:use)
  (:export #:new-project))

(defpackage #:ralexandria.prog.proj-impl
  (:use :cl)
  (:local-nicknames (#:proj #:ralexandria.prog.proj)
                    (#:strings #:ralexandria.strings)
                    (#:multiline-string #:ralexandria.reader.multiline-string)))
