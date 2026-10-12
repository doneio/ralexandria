(in-package #:asdf-user)

(defsystem #:ralexandria.prog.continuations
  :name ""
  :pathname "src"
  :depends-on (#:cl-ppcre #:ralexandria.strings)
  :components ((:file "packages")
               (:file "continuations"))
  :in-order-to ((test-op (test-op "ralexandria.prog.continuations-test"))))
