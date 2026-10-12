(cl:in-package #:asdf-user)

(defsystem #:ralexandria.prog.proj
  :name ""
  :pathname "src"
  :depends-on (#:ralexandria.strings
               #:ralexandria.reader.multiline-string)
  :components ((:file "packages")
               (:file "proj"))
  :in-order-to ((test-op (test-op "ralexandria.prog.proj-test"))))
