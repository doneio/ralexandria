(in-package #:asdf-user)

(defsystem #:ralexandria.clos.print-method-for
  :name ""
  :pathname "src"
  :depends-on (#:closer-mop)
  :components ((:file "packages")
               (:file "print-method-for"))
  :in-order-to ((test-op (test-op "ralexandria.clos.print-method-for-test"))))
