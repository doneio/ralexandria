(defpackage #:ralexandria.prog.renaming
  (:export
   #:defgeneric-functions
   #:renaming))

(defpackage #:ralexandria.prog.renaming-impl
  (:use :cl)
  (:local-nicknames (#:p #:ralexandria.prog.renaming))
  (:export
   #:process1
   #:lambda-list
   #:process2%%
   #:process2%
   #:process2
   #:subst-lambda-list-leaves))

(in-package #:ralexandria.prog.renaming-impl)

(defmacro p:defgeneric-functions (names lambda-list)
  `(progn
     ,@(mapcar (lambda (name)
                 `(defgeneric ,name ,lambda-list))
               names)))

(defun standard-generic-function-p (function)
  (typep function 'standard-generic-function))

(defgeneric lambda-list (fn))

(defmethod lambda-list ((fn standard-generic-function))
  (closer-mop:generic-function-lambda-list fn))

(defmethod lambda-list ((fn function))
  (second (function-lambda-expression fn)))

(defmethod lambda-list ((fn symbol)) ; in sbcl this is used to get the lambda-list of macros
  #+sbcl(multiple-value-bind (list unknown) (sb-introspect:function-lambda-list fn)
          (if unknown nil list)) ; the client actually uses nil in this particular module we are implementing
  #+lispworks(let ((res (LISPWORKS:FUNCTION-LAMBDA-LIST fn nil)))
    (if (eq :error res)
        nil
      res))
  #-(or sbcl lispworks)(break "Implement or the default unexplicit (&rest args) will be used by the caller of this function."))

(defun intern* (x &optional (package *package*))
  (intern (string x) package))

(defun process1 (list &aux optional body rest ignorable key head (tmp (second (member '&body list))))
  #+c(unless (null tmp)
    (print tmp))
  (let ((list (copy-tree list)))
    (setf key (member '&key list))
    (setf head
          (cond
            ((setf optional (member '&optional list))
             'list)
            ((setf body (member '&body list))
             (setf list (remove '&body list))
             'list*)
            ((setf rest (member '&rest list))
             (setf list
                   (append
                    (subseq list 0 (position '&rest list))
                    (cond
                      ((null key)
                       (cdr rest))
                      #+old(t (setf ignorable (second rest))
                              (cddr rest))
                      (t (setf ignorable (cdddr rest))
                         (list (second rest))))))
             #+old(if (null key)
                      'list*
                      'list)
             'list*)
            (t
             'list)))
    (cond
      ((and (not (null optional))
            #+hmm(null rest))
       #+c(break)
       (setf list
             (nconc (subseq list 0 (position '&optional list))
                    (mapcar (lambda (x)
                              (if (atom x)
                                  x
                                  (first x)))
                            (rest optional))))
       #+c(break))
      ((and (not (null key))
            (null rest))
       (setf list
             (nconc (subseq list 0 (position '&key list))
                    (mapcan (lambda (x)
                              (if (atom x)
                                  (list (intern* x :keyword)
                                        x)
                                  (list (intern* (first x) :keyword)
                                        (first x))))
                            (rest key))))))     
    (values
     (cons head
           (mapcar (lambda (x)
                     (if (atom x)
                         x
                         (process1 x)))
                   list))
     ignorable)))

(defun self-evaluating-p (x)
  (or (stringp x) (keywordp x)))

(defun process2%% (form &key first-time-p firstp list-and-last-p list*-and-last-p
                          (level 0))
  (let ((form (copy-tree form)))
  (when first-time-p
    (setf firstp t))
  (etypecase form
    (atom
     #+c(break)
     (cond
       (list*-and-last-p
        (format t " ,@~S)" form))
       (list-and-last-p
        (format t ",~S)" form))
       (t
        (unless (self-evaluating-p form)
          #+c(break "form:~S level:~A" form level)
          (dotimes (i level)
            (princ ",")))
        (format t "~S " form))))
    (t
     (let ((form1 (first form))
           (butlast (butlast form))
           (last (car (last form))))
       #+c(break)
       (when firstp
         (cond ((member form1 '(list*))
                (princ "`(")
                (incf level)
                #1=(map nil (lambda (x)
                           (process2%% x :firstp t :level level))
                     (cdr butlast))
                (process2%% last :list*-and-last-p t :level level))
               ((member form1 '(list))
                (when first-time-p
                  (princ "`")
                  (incf level))
                (princ "(")
                #1#
                (process2%% last :list-and-last-p t :level level)))))))))

(defun process2% (form)
  (nth-value 0
   (with-output-to-string (*standard-output*)
     (process2%% form :first-time-p t))))

(defun process2 (form)
  (read-from-string (process2% form)))

;; (process2%% cl-user::x :first-time-p t)

(defun common-lisp-symbol-p (symb)
  (eq (symbol-package symb)
      (find-package :cl)))

(defun subst-lambda-list-leaves (new-name name lambda-list)
  "Replaces NAME by NEW-NAME and reinterns all other symbols to *PACKAGE*"
  (subst-if 'unused
            (lambda (arg)
              (when (typep arg '(cons symbol))
                (let ((car (car arg)))
                  #+c(print arg)
                  (rplaca arg
                          (if (eq car name)
                              new-name
                              (if (common-lisp-symbol-p car) ; '&body
                                  car
                                  (intern (symbol-name car)
                                          *package*))))))
              nil)
            lambda-list))

(defun ensure-list (object)
  (if (consp object)
      object
      (list object)))

(defmacro p:renaming (op-type list &key (to-package (package-name *package*)))
  `(progn
     ,@(let ((to-package (find-package to-package)))
         (mapcan
          (lambda (entry &aux name new-name macrop genericp
                           (res '()))
            (setf entry (ensure-list entry))
            (multiple-value-setq (name new-name)
              (if (>= (length entry) 2)
                  (values (first entry)
                          (second entry))
                  (let ((name (first entry)))
                    (values name (intern (symbol-name name) to-package)))))
            (dolist (op-type (ensure-list op-type))
              (push
               (ecase op-type
                 ((:generic :method :function :macro)
                  (let* ((fn (or (setf macrop (macro-function name))
                                 (symbol-function name)))
                         (lambda-list (cond
                                        (macrop (lambda-list name))
                                        (t
                                         (setf genericp
                                               (standard-generic-function-p fn))
                                         (lambda-list fn))))
                         (lambda-list (copy-tree lambda-list))
                         (lambda-list (or (subst-lambda-list-leaves
                                           new-name name lambda-list)
                                          '(&rest args))))
                    #+c(defparameter cl-user::ll lambda-list)
                    (unless (or (and (eq op-type :function)
                                     (or genericp macrop))
                                (and (eq op-type :macro)
                                     (not macrop))
                                (and (member op-type '(:generic :method))
                                     (not genericp)))
                     
                      (ecase op-type
                        (:function
                         `(defun ,new-name ,lambda-list
                            ,@#1=(multiple-value-bind (args ignorable) (process1 lambda-list)
                                   `(,@(unless (null ignorable)
                                         `((declare (ignore ,@ignorable))))
                                     (apply ',name ,(process2 args))))))
                        (:generic
                         `(defgeneric ,new-name ,lambda-list))
                        (:method
                            `(defmethod ,new-name ,lambda-list
                               ,@#1#))
                        (:macro
                         `(defmacro ,new-name ,lambda-list
                            (cons ',name ,(process2 (process1 lambda-list))))))
                      )))
                 (:symbol `(define-symbol-macro ,new-name ,name)))
               res))
            (nreverse res))
          list))))
