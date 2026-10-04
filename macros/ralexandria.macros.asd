(in-package #:asdf-user)

(defsystem #:ralexandria.macros
  :name ""
  :depends-on ()
  :pathname "src"
  :components ((:file "packages")
               (:file "macros"))
  :in-order-to ((test-op (test-op "ralexandria.macros-test"))))
