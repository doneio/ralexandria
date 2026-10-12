(in-package #:asdf-user)

(defsystem #:ralexandria.strings.regex
  :name ""
  :pathname "src"
  :depends-on (#:ralexandria.macros #:cl-ppcre)
  :components ((:file "packages")
               (:file "regex"))
  :in-order-to ((test-op (test-op "ralexandria.strings.regex-test"))))
