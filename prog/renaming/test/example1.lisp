(defpackage #:ds.containers.list
  (:use)
  (:export
   ;; classes
   #:abstract-list
   #:list
   ;; functions
   #:make-list
   ;; generic functions
   #:raw-list
   #:emptyp
   #:insert
   #:delete
   #:length
   #:member
   ;;
   #:clear
   #:length
   #:first
   #:second
   #:last
   #:find
   #:find-if))

(defpackage #:ds.containers.list-impl
  (:use #:cl)
  (:local-nicknames (#:L #:ds.containers.list)))

(defpackage #:ds.containers.set
  (:use)
  (:export
   ;; classes
   #:abstract-set
   #:set
   ;; functions
   #:make-set
   ;; generic functions
   #:raw-list
   #:emptyp
   #:insert
   #:delete
   #:cardinal
   #:belongs
   #:-
   #:subset
   #:equal))

(defpackage #:ds.containers.set-impl
  (:use #:cl)
  (:local-nicknames (#:S #:ds.containers.set)
                    (#:L #:ds.containers.list)))

(in-package #:ds.containers.list-impl)

(defclass L:abstract-list () ())
(defclass L:list (L:abstract-list)
  ((contents :initform '() :initarg :contents :accessor L:raw-list)))

(defun L:make-list (&optional contents)
  (make-instance 'L:list :contents contents))

;;; Shorthand to define generic functions with the same lambda-list
(ralexandria.prog.renaming:defgeneric-functions (L:emptyp L:clear L:length L:first L:second L:last)
    (list))

(ralexandria.prog.renaming:defgeneric-functions (L:member L:find)
    (thing list &rest keys &key key test test-not))

(defgeneric L:find-if (predicate list &key from-end start end key))
(defgeneric L:insert (thing list &key at-end key test test-not duplicates))
(defgeneric L:delete (thing list &rest keys &key from-end test test-not start end count key))
(defmethod L:emptyp ((list L:list))
  (null (L:raw-list list)))

(defmethod L:member (thing (list L:list) &rest keys &key key test test-not)
  (declare (ignorable keys key test test-not))
  (let ((member (apply #'cL:member thing (L:raw-list list) keys)))
    (unless (null member)
      (L:make-list member))))

(defmethod L:delete (thing (list L:list) &rest keys &key from-end (test #'eql) test-not (start 0) end count key)
  (declare (ignore from-end key test test-not start count key end))
  (setf (L:raw-list list)
	(apply #'cl:delete thing (L:raw-list list) keys))
  list)

(defmethod L:length ((list L:list))
  (cl:length (L:raw-list list)))

(in-package #:ds.containers.set-impl)

;;; automatically define generic functions
;;; S:raw-list S:emptyp S:insert S:delete S:cardinal S:belongs 
;;; and methods which in their bodies call
;;; L:emptyp L:insert L:delete L:length L:member respectively.
;;; If in the future we want to redefine the set module
;;; to not depend on List but on something else,
;;; the clients will not be affected.
(ralexandria.prog.renaming:renaming (:generic :method :function :macro)
          (L:raw-list
           L:emptyp
           L:insert
           L:delete
           (L:length S:cardinal)
           (L:member S:belongs))
          :to-package S)

;;; New generic functions specific to sets:

(defgeneric S:- (set1 set2))
(defgeneric S:subset (set1 set2 &key test))
(defgeneric S:equal (set1 set2 &key test))

(defclass S:abstract-set (L:abstract-list) ())

(defclass S:set (L:list S:abstract-set)
  ())

(defmethod initialize-instance :before ((object S:set) &key contents)
  (assert (no-duplicates-p contents)))

(defun no-duplicates-p (list)
  (if (null list)
      t
      (and (not (member (first list) (rest list)))
           (no-duplicates-p (rest list)))))

(defun S:make-set (&optional contents)  
  (make-instance 'S:set :contents contents))

(defun ralexandria.prog.renaming-test:example1-test ()
  (let ((s1 (make-instance 'S:set :contents '(1 2 3 4))))
    (assert (not (S:emptyp s1)))
    (assert (= (S:cardinal s1)
               4))
    (assert (S:belongs 2 s1))))
 
