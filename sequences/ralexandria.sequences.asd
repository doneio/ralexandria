(cl:in-package #:asdf-user)

(defsystem :ralexandria.sequences
  :name ""
  :depends-on ()
  :components ((:module "src"
                :components ((:file "packages")
                             (:file "sequences"))))
  :in-order-to ((test-op (test-op "ralexandria.sequences-test"))))
