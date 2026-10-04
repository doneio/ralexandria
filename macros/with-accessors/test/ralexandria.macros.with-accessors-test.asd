(cl:in-package #:asdf-user)

(defsystem #:ralexandria.macros.with-accessors-test
  :name ""
  :depends-on (#:ralexandria.macros.with-accessors)
  :components ((:file "packages")
               (:file "with-accessors"))
  :perform (test-op (operation component)
	    (uiop:symbol-call 'ralexandria.macros.with-accessors-test 'do-tests)))
