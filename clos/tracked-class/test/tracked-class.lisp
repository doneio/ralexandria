(in-package #:ralexandria.clos.tracked-class-impl)

(defun ralexandria.clos.tracked-class-test:do-tests ()
  (ralexandria.clos.tracked-class-test:test-tracked-class)
  (format t "ralexandria.clos.tracked-class all tests passed.~%"))

(defclass data ()
  ((data :accessor data :initarg :data)))

(p:ensure-tracked 'data)

;; (setf (find-class 'data) nil)

(defun ralexandria.clos.tracked-class-test:test-tracked-class ()
  (let* ((object (make-instance 'data :data 1))
         (ver0 (p:object-version object))
         ver1 ver2)
    #+(or)(describe object)
    (assert #0=(= (p:object-version object) ver0))
    (setf (data object) 2)
    (assert (not #0#))
    (setf ver1 (p:object-version object))
    (assert #1=(= (p:object-version object) ver1))
    (p:increase-version object)
    (assert (not #1#))
    (setf ver2 (p:object-version object))
    (assert (= 2 ver2))))
