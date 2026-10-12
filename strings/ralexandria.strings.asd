(cl:in-package #:asdf-user)

(defsystem #:ralexandria.strings
  :name ""
  :pathname "src"
  :depends-on (#:cl-ppcre)
  :components ((:file "packages")
               (:file "strings"))
  :in-order-to ((test-op (test-op "ralexandria.strings-test"))))
