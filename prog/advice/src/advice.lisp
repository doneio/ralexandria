(in-package #:ralexandria.prog.advice-impl)

(defun flatten (form)
  (cond ((null form) nil)
        ((atom form) (list form))
        (t (mapcan #'flatten form))))

(defun ensure-function (f)
  (etypecase f
    (symbol (symbol-function f))
    (function f)
    ;; it's fboundp:
    (cons (closer-mop:ensure-generic-function f))))

(defun ensure-list (obj)
  (if (listp obj) obj (list obj)))

(defvar a:*advisors* (make-hash-table))

(defclass advisor ()
  ((original-function :accessor original-function :initarg :original-function)
   (around-advices :accessor around-advices :initform (make-empty-around-advices) :initarg :around-advices)))

(defmethod print-object ((obj advisor) stream)
  (print-unreadable-object (obj stream :type nil :identity t)
    (format stream "(~{~a~^,~}) ~A"
            (around-advices obj)
            (original-function obj))))

(defun a:get-advisor (hashkey)
  (declare (inline a:get-advisor))
  (gethash hashkey a:*advisors*))

(defsetf a:get-advisor (hashkey) (new-advisors)
  `(setf (gethash ,hashkey a:*advisors*)
     ,new-advisors))

(defun canonic-hashkey (&rest args)
  "Concatenates arguments with underlines between them"
  (intern (reduce (lambda (a b)
		    (concatenate 'string a "_" b))
		  (mapcar #'string args))
          :keyword))

(defun macro-or-function-from (sym)
  (if (and (symbolp sym)
	   (macro-function sym))
      (macro-function sym)
      (ensure-function sym)))

(defun emptyp (around-advices)
  (null around-advices))

(defun make-empty-around-advices ()
  (list))

(defun make-around-advices (advice-symbol)
  (list advice-symbol))

(defun around-advices-number (advisor)
  (length (around-advices advisor)))

(defun not-found-value-p (around-advice)
  (null around-advice))

(defun find-around-advice (name advisor &key next)
  (let ((advices-list
          (member-if (lambda (s)
                       (string= (symbol-name s)
	                        name))
                     (around-advices advisor))))
    (if next
        (second advices-list)
        (first advices-list))))

(defmacro push-around-advice (advice-symbol advisor)
  `(push ,advice-symbol (around-advices ,advisor)))

(defun newest-advice (advisor)
  (first (around-advices advisor)))

(defun advice-name= (symbol-one symbol-two)
  (string= (string symbol-one)
           (string symbol-two)))

(defun delete-advice (name advisor)
  (setf (around-advices advisor)
        (delete-if (lambda (around-advice)
                     (advice-name= name around-advice))
                   (around-advices advisor))))

(defun set-to-newest-advice (fn-sym advisor)
  "Sets the function of fn-sym to be the newest advice function
if such an advice function is available, otherwise to the original-function."
  (let* ((newest-advice (newest-advice advisor))
         (fn (ensure-function (if (not-found-value-p newest-advice)
                                  (original-function advisor)
                                  newest-advice))))
    (if (macro-function fn-sym)
	(setf (macro-function fn-sym)
	      fn)
	(setf (symbol-function fn-sym)
	      fn))))

(defun add-or-update-advice (fn-sym advice-name qualifier lambda)
  "
(a:defadvice (sum add-mean :around) (nums) (...body...))
Params:
fn-sym advice-symbol qualifier    lambda
  sum   #:add-mean   :around    (...body...)
 hashkey
SUM_AROUND
a:*advisors* hashtable:
SUM_AROUND = <:around-advices (#:ADD-MEAN) :original-function #<FUNCTION SUM>>
"
  (let ((hashkey   (canonic-hashkey fn-sym qualifier))
        (fn-sym-fn (macro-or-function-from fn-sym))
        (advice-symbol (make-symbol advice-name)))
    (multiple-value-bind (advisor advisor-found-p) (a:get-advisor hashkey)
      (if advisor-found-p
          (with-accessors ((original-function original-function)
                           (newest-advice newest-advice)) advisor
            (unless (and (not (not-found-value-p newest-advice))
                         (eq (macro-or-function-from newest-advice)
                             fn-sym-fn))
	      ;; fn-sym was redefined meanwhile, to be some new function
	      (setf original-function fn-sym-fn))
	    (when (not-found-value-p (find-around-advice advice-name advisor))
              (push-around-advice advice-symbol advisor)))
          (setf advisor
                (make-instance 'advisor
                               :original-function fn-sym-fn
                               :around-advices (make-around-advices advice-symbol))))
      (setf (fdefinition (newest-advice advisor)) lambda)
      (set-to-newest-advice fn-sym advisor)
      (unless advisor-found-p
        (setf (a:get-advisor hashkey) advisor)))))

(defmacro without-package-locks (&body body)
  `(#-sbcl progn #+sbcl sb-ext:without-package-locks
    ,@body))
  
(defmacro a:defadvice ((fn-sym name &optional (qualifier :around)) args &body body)
  (assert (eql :around qualifier))
  (check-type fn-sym symbol)
  (check-type name symbol)
  (setf name (string name))
  (let* ((next (gensym "NEXT"))
	 (advisor (gensym "ADVISOR")))
    `(without-package-locks
       (assert (fboundp ',fn-sym))
       ,(if (endp (member 'a:call-next-advice (flatten body)))
            `#1=(add-or-update-advice ',fn-sym ,name ,qualifier
			              (lambda ,args
			                (without-package-locks
			                  ,@body)))
	    `(flet ((a:call-next-advice (&rest args)
		      (let* ((,advisor (a:get-advisor ',(canonic-hashkey fn-sym qualifier))) ; an advisor exists because this is inside call-next-advice
			     (,next (find-around-advice ',name                               ; after an advisor was already created by add-or-update-advice
						        ,advisor
                                                        :next t)))
                        (when (not-found-value-p ,next)
                          (setf ,next (original-function ,advisor)))
		        (if (null (macro-function ',fn-sym)) ; I forgot exactly how this if block works but the tests pass so it must be correct
			    (apply ,next args)
                            (progn
			      (setf (macro-function ',fn-sym)
				    ,next)
			      (prog1 (apply #'macroexpand-1 args)
				(when (eql ,next (original-function ,advisor))
				  (setf (macro-function ',fn-sym)
					(fdefinition (newest-advice ,advisor)))))))))
                    (a:call-function (&rest args)
		      (apply ',fn-sym args)))
	       #1#)))))

(defun a:remove-advice (fn-sym name &optional (qualifier :around))
  (without-package-locks
    (let ((advisor (a:get-advisor (canonic-hashkey fn-sym qualifier))))
      (delete-advice name advisor)  ;; THIS BRANCH change to delete by name
      (set-to-newest-advice fn-sym advisor))))

(defmacro a:with-advice ((fn-sym name &optional (qualifier :around)) args advice-body &body body)
  `(PROGN
     (a:defadvice (,fn-sym ,name ,qualifier) ,args
       ,advice-body)
     (unwind-protect (progn ,@body)
       (a:remove-advice ',fn-sym ',name))))

(defmacro a:defadvices ((fn-syms name qualifier) args &body body)
  (setf fn-syms (ensure-list fn-syms))
  `(PROGN
     ,@(loop :for fn-sym :in fn-syms :collect
	     `(a:defadvice (,fn-sym ,name ,qualifier) ,args ,@body))))

(defun a:remove-advices (fn-syms names)
  (setf fn-syms (ensure-list fn-syms))
  (setf names (ensure-list names))
  `(progn
     ,@(loop :for fn-sym :in fn-syms :collect
	     `(progn
		,@(loop :for name :in names :collect
			`(a:remove-advice (,fn-sym ,name)))))))

(defmacro a:rdefadvice ((fn-sym name qualifier) &body body)
  "handy, just prefix a:defadvice with a r to remove the method."
  (declare (ignorable qualifier))
	(declare (ignore body))
  `(a:remove-advice ',fn-sym ',name))


(defmacro a:rdefadvices ((fn-syms name qualifier) args &body body)
  (setf fn-syms (ensure-list fn-syms))
  `(PROGN
    ,@(loop :for fn-sym :in fn-syms :collect
	    `(a:rdefadvice (,fn-sym ,name ,qualifier) ,args ,@body))))
