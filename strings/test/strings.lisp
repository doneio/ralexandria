(cl:in-package #:ralexandria.strings-test)

(defun do-tests ()
  (test-strings+))

(defun test-strings+ ()
  (assert
   (and
     #+noneed(equalp #(2 4) (strings:+ #(2) #(4)))
     (equalp (strings:+ "a" 2) "a2")
     (equalp (strings:+ "a" nil) "a")
     (equalp (strings:+ ) "")))
  (format t "ralexandria.strings all tests passed.~%"))
