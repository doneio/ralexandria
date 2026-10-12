(in-package #:asdf-user)

(defsystem #:ralexandria.macros.with-accessors
  :name ""
  :pathname "src"
  :components ((:file "packages")
               (:file "with-accessors"))
  :in-order-to ((test-op (test-op "ralexandria.macros.with-accessors-test"))))
