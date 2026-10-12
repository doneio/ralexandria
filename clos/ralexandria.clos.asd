(in-package #:asdf-user)

(defsystem #:ralexandria.clos
  :name ""
  :pathname "src"
  :depends-on ()
  :components ((:file "packages")
               (:file "clos"))
  :in-order-to ((test-op (test-op "ralexandria.clos-test"))))
