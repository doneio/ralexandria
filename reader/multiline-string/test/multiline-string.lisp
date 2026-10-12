(cl:in-package #:ralexandria.reader.multiline-string-impl)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defvar *original-readtable* (copy-readtable))
  (set-dispatch-macro-character #\# #\> #'multiline-string:reader))

(defun ralexandria.reader.multiline-string-test:do-tests ()
  (assert (string= #>END
this is a stringEND "this is a string"))
  (format t "ralexandria.reader.multiline-string-impl all tests passed."))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (setf *readtable* *original-readtable*))
