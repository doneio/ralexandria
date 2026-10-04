(cl:in-package #:asdf-user)

(defsystem #:ralexandria.reader.multiline-string
  :name ""
  :pathname "src"
  :components ((:file "packages")
               (:file "multiline-string"))
  :in-order-to ((test-op (test-op "ralexandria.reader.multiline-string-test"))))
