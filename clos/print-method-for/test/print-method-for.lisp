(in-package #:ralexandria.clos.print-method-for-impl)

(defun ralexandria.clos.print-method-for-test:do-tests ()
  (assert
   (string=
    (format nil "~A"
            (make-instance 'role
                           :name "Administrator"
                           :start-date "01.01.2026"
                           :expiry-date "12.12.2026"))
    "<#R_Administrator :start-date 01.01.2026 :expiry-date 12.12.2026 :enabled T>"))
  (format t "ralexandria.clos.print-method-for all tests passed.~%"))

(defclass enabled-mixin ()
  ((%enabled :initarg :enabled :initform t :accessor enabled
	     :type boolean :allocation :class)))

(defun date-default-value ()
  nil)

(defun date-default-value-p (val)
  (eq val (date-default-value)))

(defclass expires-mixin ()
  ((%start-date :initarg :start-date :accessor start-date :initform (date-default-value))
   (%expiry-date :initarg :expiry-date :accessor expiry-date :initform (date-default-value))))

(defmethod print-object ((object enabled-mixin) stream)
  (format stream " :enabled ~A" (enabled object)))

(defmethod print-object ((object expires-mixin) stream)
  (unless (date-default-value-p (start-date object))
    (format stream " :start-date ~A" (start-date object)))
  (unless (date-default-value-p (expiry-date object))
    (format stream " :expiry-date ~A" (expiry-date object))))

(defclass permission (enabled-mixin)
  ())

(defclass role (enabled-mixin expires-mixin)
  ((%name :initarg :name :accessor name)
   (%direct-permissions :initarg :...)))

(defmethod print-object ((object permission) stream)
  (format stream "<#P_~A" (class-name (class-of object)))
  (p:call-print-method-for 'enabled-mixin object stream)
  (format stream ">"))

(defmethod print-object ((object role) stream)
  (format stream "<#R_~A" (name object))
  (p:call-print-method-for 'expires-mixin object stream)	 ;
  (p:call-print-method-for 'enabled-mixin object stream)	 ;
  (format stream ">"))
