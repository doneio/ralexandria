(in-package #:asdf-user)

(defsystem #:ralexandria.clos-test
  :name ""
  :depends-on (#:ralexandria.clos)
  :components ((:file "packages")
               (:file "clos"))
  :perform (test-op (operation component)
		    (uiop:symbol-call 'ralexandria.clos-test 'do-tests)))
