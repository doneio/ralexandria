(cl:defpackage #:ralexandria.clos-test
  (:use)
  (:export #:do-tests #:test-class-inherited-by-p))

(in-package #:ralexandria.clos-impl)

(defun ralexandria.clos-test:do-tests ()
  (ralexandria.clos-test:test-class-inherited-by-p))
