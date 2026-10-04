(in-package #:asdf-user)

(defsystem #:ralexandria.clos.print-method-for-test
  :name ""
  :depends-on (#:ralexandria.clos.print-method-for)
  :components ((:file "packages")
               (:file "print-method-for"))
  :perform (test-op (operation component)
              (uiop:symbol-call 'ralexandria.clos.print-method-for-test 'do-tests)))
