(in-package #:asdf-user)

(defsystem #:ralexandria.clos.tracked-class
  :name ""
  :pathname "src"
  :depends-on (#:closer-mop #:stealth-mixin #:ralexandria.clos)
  :components ((:file "packages")
               (:file "tracked-class"))
  :in-order-to ((test-op (test-op "ralexandria.clos.tracked-class-test"))))
