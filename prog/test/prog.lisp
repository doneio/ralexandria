(cl:in-package #:ralexandria.prog-impl)

(defun ralexandria.prog-test:do-tests ()
  (test-toggle)
  (test-string-case)
  (format t "~&ralexandria.prog all tests passed.~%"))

(defun test-toggle ()
  (let ((false nil))
    (assert (prog:toggle false))))

(defun test-string-case ()
  (assert (= 2
           (prog:string-case "ABC"
             ("A" 1)
             ("ABC" 2)
             ("ABCD" 3)))))
