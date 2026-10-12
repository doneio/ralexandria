(cl:in-package #:asdf-user)

(defsystem #:ralexandria.prog.proj-test
  :name ""
  :depends-on (#:ralexandria.prog.proj)
  :components ((:file "packages")
               (:file "proj"))
  :perform (test-op (operation component)
		    (uiop:symbol-call 'ralexandria.prog.proj-test 'do-tests)))
