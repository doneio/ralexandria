(cl:in-package #:asdf-user)

(defsystem #:ralexandria.prog.renaming
  :name ""
  :depends-on ("closer-mop")
  :components ((:file "renaming"))
  :in-order-to ((test-op (test-op "ralexandria.prog.renaming-test"))))

#+sbcl
(defmethod asdf:perform :before ((operation asdf:prepare-op)
                            (system (eql (asdf:find-system :ralexandria.prog.renaming))))
 (require :sb-introspect))
