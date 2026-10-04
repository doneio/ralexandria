(cl:in-package #:asdf-user)

(defsystem :ralexandria.prog-test
  :name ""
  :depends-on (#:ralexandria.prog)
  :components ((:file "packages")
	       (:file "prog"))
  :perform (test-op (operation component)
                    (uiop:symbol-call 'ralexandria.prog-test 'do-tests)))
