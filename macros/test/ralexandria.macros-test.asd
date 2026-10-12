(cl:in-package #:asdf-user)

(defsystem #:ralexandria.macros-test
  :name ""
  :depends-on (#:ralexandria.macros)
  :components ((:file "packages")
               (:file "macros"))
  :perform (test-op (operation component)
	    (uiop:symbol-call 'ralexandria.macros-test 'do-tests)))
