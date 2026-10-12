(cl:in-package #:asdf-user)

(defsystem :ralexandria.prog
  :name ""
  :depends-on ()
  :pathname "src"
  :components ((:file "packages")
               (:file "prog"))
  :in-order-to ((test-op (test-op "ralexandria.prog-test"))))

#|
ralexandria.prog.symbol-export-advice
adds a restart that automatically exports a missing symbol
|#
