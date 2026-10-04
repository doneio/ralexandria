(in-package #:ralexandria.clos.tracked-class-impl)

(defun make-weak-key-hash-table (&rest args)
  (apply #'make-hash-table
         #+sbcl      :weakness #+sbcl :key
         #+ecl       :weakness #+ecl :key
         #+ccl       :weak     #+ccl :key
         #+clisp     :weak     #+clisp :key
         #+lispworks :weak-kind #+lispworks :key
         #+allegro   :weak-keys #+allegro t
         args))

(defparameter p:*object-versions*
  (make-weak-key-hash-table :test 'eq))

(defclass p:tracked-class () ())

(defmethod mop:validate-superclass ((class p:tracked-class) (super standard-class))
  t)

(defun p:increase-version (object)
  (incf (gethash object p:*object-versions* 0)))

(defmethod (setf mop:slot-value-using-class) :around
    (new-value class (object p:tracked-class) slot)
  (prog1 (call-next-method)
    (p:increase-version object)))

(defun p:object-version (object)
  (gethash object p:*object-versions* 0))

(defun (setf p:object-version) (version object)
  (setf (gethash object p:*object-versions*) version))

(defmethod shared-initialize :after ((object p:tracked-class) slot-names &rest initargs)
  (declare (ignore slot-names initargs))
  (setf (p:object-version object) 0))

(defun p:ensure-tracked (object-or-class)
  (let ((victim-class))
    (setf victim-class
          (if (symbolp object-or-class)
              (setf victim-class object-or-class)
              (type-of object-or-class)))
    (unless (or (ralexandria.clos:class-inherited-by-p 'p:tracked-class victim-class)
                (eql victim-class 'standard-class))
      (stealth-mixin:add-mixin 'p:tracked-class victim-class))))
