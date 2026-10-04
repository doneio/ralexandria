(in-package #:ralexandria.clos.print-method-for-impl)

(defun p:print-method-for (class)
  ;; also see https://quickdocs.org/utilities.print-items
  (closer-mop:method-function
   (find-method #'print-object
		'()
		(mapcar #'find-class (list class t)))))

(defun p:call-print-method-for (class &rest params)
  (funcall (p:print-method-for class)
	   params
	   '()))

