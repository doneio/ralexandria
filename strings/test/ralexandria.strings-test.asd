(cl:in-package #:asdf-user)

(defsystem #:ralexandria.strings-test
  :name ""
  :depends-on (#:ralexandria.strings)
  :components ((:file "packages")
               (:file "strings"))
  :perform (test-op (operation component)
		    (uiop:symbol-call 'ralexandria.strings-test 'do-tests)))
