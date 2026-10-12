(cl:in-package #:asdf-user)

(defsystem :ralexandria.prog.advice-test
  :name ""
  :depends-on (#:ralexandria.prog.advice)
  :components ((:file "packages")
	       (:file "advice"))
  :perform (test-op (operation component)
		    (uiop:symbol-call 'ralexandria.prog.advice-test 'do-tests)))
