(in-package #:asdf-user)

(defsystem #:ralexandria.prog.continuations-test
  :name ""
  :depends-on (#:ralexandria.prog.continuations)
  :components ((:file "packages")
               (:file "continuations"))
  :perform (test-op (operation component)
              (uiop:symbol-call 'ralexandria.prog.continuations-test 'do-tests)))
