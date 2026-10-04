(in-package #:ralexandria.clos-impl)

(defclass animal () ())
(defclass dog (animal) ())
(defclass cat (animal) ())
(defclass poodle (dog) ())

(defun ralexandria.clos-test:test-class-inherited-by-p ()
  (assert (clos:class-inherited-by-p 'standard-object 'dog))
  (assert (clos:class-inherited-by-p 't 'dog))
  ;; direct inheritance
  (assert (clos:class-inherited-by-p 'animal 'dog))
  (assert (clos:class-inherited-by-p (find-class 'animal) 'dog))
  (assert (clos:class-inherited-by-p 'animal (find-class 'dog)))
  ;; direct inheritance
  (assert (clos:class-inherited-by-p 'dog 'poodle))
  ;; reversed
  (assert (not (clos:class-inherited-by-p 'dog 'animal)))
  ;; deep level inheritance
  (assert (clos:class-inherited-by-p 'animal 'poodle))
  (assert (clos:class-inherited-by-p
           (find-class 'animal) (find-class 'poodle)))
  ;; self inheritance
  (assert (clos:class-inherited-by-p 'animal 'animal))
  ;; siblings
  (assert (not (clos:class-inherited-by-p 'dog 'cat)))
  (assert (not (clos:class-inherited-by-p 'cat 'dog)))
  ;; different offsprings
  (assert (not (clos:class-inherited-by-p 'cat 'poodle)))
  (assert (not (clos:class-inherited-by-p
                (find-class 'cat) (find-class 'poodle))))
  #+avoidwarnings(let ((missing (gensym "NO-SUCH-CLASS-")))
    (assert (not (clos:class-inherited-by-p 'animal missing)))
    (assert (not (clos:class-inherited-by-p missing 'dog))))
  (format t "ralexandria.clos all tests passed.~%"))
