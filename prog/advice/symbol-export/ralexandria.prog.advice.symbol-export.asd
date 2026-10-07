(cl:in-package #:asdf-user)
            
(defsystem #:ralexandria.prog.advice.symbol-export
  :name ""
  :depends-on ("ralexandria.prog.advice" "cl-ppcre")
  :components ((:file "code"))
  :in-order-to ((test-op (test-op "ralexandria.prog.advice.symbol-export-test"))))
