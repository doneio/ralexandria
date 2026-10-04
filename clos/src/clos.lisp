(in-package #:ralexandria.clos-impl)

(defun clos:class-inherited-by-p (super-class sub-class)
  (subtypep sub-class super-class)) ; this should be enough
