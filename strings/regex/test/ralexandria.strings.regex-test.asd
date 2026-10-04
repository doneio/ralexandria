(in-package #:asdf-user)

(defsystem #:ralexandria.strings.regex-test
  :name ""
  :depends-on (#:ralexandria.strings.regex)
  :components ((:file "packages")
               (:file "regex"))
  :perform (test-op (operation component)
		    (uiop:symbol-call 'ralexandria.strings.regex-test 'do-tests)))
