(cl:in-package #:asdf-user)

(defsystem :ralexandria.sequences-test
  :name ""
  :depends-on (#:ralexandria.sequences)
  :components ((:file "packages")
	       (:file "sequences"))
  :perform (test-op (operation component)
		    (uiop:symbol-call 'ralexandria.sequences-test 'do-tests)))
