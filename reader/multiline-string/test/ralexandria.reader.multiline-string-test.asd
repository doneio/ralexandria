(cl:in-package #:asdf-user)

(defsystem #:ralexandria.reader.multiline-string-test
  :name ""
  :depends-on (#:ralexandria.reader.multiline-string)
  :components ((:file "packages")
               (:file "multiline-string"))
  :perform (test-op (operation component)
		    (uiop:symbol-call 'ralexandria.reader.multiline-string-test 'do-tests)))
