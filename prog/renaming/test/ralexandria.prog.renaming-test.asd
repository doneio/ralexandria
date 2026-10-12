(cl:in-package #:asdf-user)

(defsystem :ralexandria.prog.renaming-test
  :name ""
  :depends-on (#:ralexandria.prog.renaming)
  :components ((:file "packages")
	       (:file "example1")
               (:file "renaming"))
  :perform (test-op (operation component)
                    (uiop:symbol-call 'ralexandria.prog.renaming-test 'do-tests)))
