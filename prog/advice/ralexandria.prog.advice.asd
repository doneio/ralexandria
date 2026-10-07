(cl:in-package #:asdf-user)

(defsystem :ralexandria.prog.advice
  :pathname "src"
  :depends-on (:closer-mop)
  :components ((:file "packages")
               (:file "advice"))
  :in-order-to ((test-op (test-op "ralexandria.prog.advice-test"))))
