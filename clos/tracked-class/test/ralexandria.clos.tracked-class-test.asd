(in-package #:asdf-user)

(defsystem #:ralexandria.clos.tracked-class-test
  :name ""
  :depends-on (#:ralexandria.clos.tracked-class)
  :components ((:file "packages")
               (:file "tracked-class"))
  :perform (test-op (operation component)
              (uiop:symbol-call 'ralexandria.clos.tracked-class-test 'do-tests)))
