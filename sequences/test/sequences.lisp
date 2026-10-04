(cl:in-package #:ralexandria.sequences-impl)

(defun ralexandria.sequences-test:do-tests ()
  (test-getf*)
  (test-all-elements-different-p)
  (test-remove-plist-properties)
  (format t "ralexandria.sequences all tests passed.~%"))

(defun test-getf* ()
  (let ((lst (copy-tree '(:cfg (:a 4)))))
    (assert
     (equalp
      (list
       (s:getf* lst (:cfg :a))
       (progn
         (setf (s:getf* lst (:cfg :a)) ; here we modify lst
	       5) ; that is why we had to use copy-tree
         lst))
      '(4 (:CFG (:A 5)))))))

(defun test-all-elements-different-p ()
  (assert
   (equalp
    (list
     (s:all-elements-different-p (list 1 2 3 'a))
     (s:all-elements-different-p (list 1 2 3 'a 1)))
    (list t nil))))

(defun test-remove-plist-properties ()
  (assert
   (equalp
    (s:remove-plist-properties (list :a 1 :b 2 :c 3 :d 4) '(:a :c))
    '(:B 2 :D 4))))
