(cl:in-package #:ralexandria.prog.renaming-test)

(defun do-tests ()
  (test-defgeneric-functions)
  (test-process1-1)
  (test-process1-2)
  (test-process2-1)
  (test-subst-lambda-list-leaves-1)
  (test-renaming-macros-1)
  (let ((p :ralexandria.prog.renaming-test-isolated))
    (uiop:symbol-call p 'test-renaming-macros-2)
    (uiop:symbol-call p 'test-renaming-symbols))
  (example1-test)
  (format t "ralexandria.prog.renaming all tests passed.~%"))

(defun macroexpansion (form)
  (nth-value 0 (macroexpand-1 form)))

(defmacro with-current-package (&body body)
  "Useful when testing functions that call intern."
  `(let ((*package* (find-package #.(package-name *package*))))
     ,@body))

(defun test-defgeneric-functions ()
  (assert
   (equalp
    (macroexpansion
     '(p:defgeneric-functions (member find)
       (thing list &rest keys &key key test test-not)))
    '(PROGN
      (DEFGENERIC MEMBER
          (THING LIST &REST KEYS &KEY KEY TEST TEST-NOT))
      (DEFGENERIC FIND
          (THING LIST &REST KEYS &KEY KEY TEST TEST-NOT))))))

#+c(p-impl:process1 cl-user::ll)

(defun test-process1-1 ()
  (assert
   (equalp
    (mapcar #'p-impl:process1
            (list
             '(OBJECT)
             '(FUNCTION LIST)
             '(FUNCTION FIRST-LIST &REST MORE-LISTS)
             '(PREDICATE LIST &KEY FROM-END START END KEY)
             '((THING LIST &KEY (SKIP-FIRST 0) SKIP-LAST) &BODY BODY)
             '(ARGS &OPTIONAL (PACKAGE *PACKAGE*))))
    '(
      (LIST OBJECT)
      (LIST FUNCTION LIST)
      (LIST* FUNCTION FIRST-LIST MORE-LISTS)
      (LIST PREDICATE LIST :FROM-END FROM-END :START START :END END :KEY KEY)
      (LIST* (LIST THING LIST :SKIP-FIRST SKIP-FIRST :SKIP-LAST SKIP-LAST) BODY)
      (LIST ARGS PACKAGE)))))

(defun test-process1-2 ()
  (assert
   (equalp
    (multiple-value-list
     (p-impl:process1 '(THING LIST &REST KEYS &KEY AT-END KEY TEST TEST-NOT DUPLICATES)))
    '((LIST* THING LIST KEYS)
      (AT-END KEY TEST TEST-NOT DUPLICATES)))))

(defun test-process2-1 ()
  (assert
   (equalp
    (with-current-package
        (mapcar #'p-impl:process2%
                (list
                 '(LIST OBJECT)
                 '(LIST FUNCTION LIST)
                 '(LIST* FUNCTION FIRST-LIST MORE-LISTS)
                 '(LIST PREDICATE LIST :FROM-END FROM-END :START START :END END :KEY KEY)
                 '(LIST* (LIST THING LIST :SKIP-FIRST SKIP-FIRST :SKIP-LAST SKIP-LAST) BODY))))
    (list
     "`(,OBJECT)"
     "`(,FUNCTION ,LIST)"
     "`(,FUNCTION ,FIRST-LIST  ,@MORE-LISTS)"
     "`(,PREDICATE ,LIST :FROM-END ,FROM-END :START ,START :END ,END :KEY ,KEY)"
     "`((,THING ,LIST :SKIP-FIRST ,SKIP-FIRST :SKIP-LAST ,SKIP-LAST) ,@BODY)"))))

(defun test-subst-lambda-list-leaves-1 ()
  (assert
   (equalp
    (with-current-package
        (list
         (p-impl:subst-lambda-list-leaves 'new! 'cl:+ nil)
         (p-impl:subst-lambda-list-leaves 'new! 'cl:+ (copy-tree '(1 cl:+ ((3 (cl-user::C D 2 3)) 1 2) (F 9))))))
    (list
     NIL
     '(1 NEW! ((3 (C D 2 3)) 1 2) (F 9))))))


(cl:eval-when (:compile-toplevel :load-toplevel :execute)
  (DEFMACRO iterate ((THING LIST &KEY (SKIP-FIRST 0)) &BODY BODY)
    (let ((slist (gensym "LIST")))
      `(let ((,slist ,list))
         (dolist (,thing (subseq ,slist ,skip-first))
	   ,@body)))))

(defun test-renaming-macros-1 ()
  (assert
   (=
    (progn
      (p:renaming (:macro)
                  ((iterate iterate-clone)))
      (eval
       `(let ((total 0))
          (iterate-clone (i (list 4 5))
                         (incf total i))
          total)))
    9)))

#+ok(with-accessors ((car car)) (list 1 2)
car)

(defmacro my-with-accessors (accessors object &body body)
  `(cl:with-accessors ,(mapcar (lambda (entry)
				 (if (atom entry)
				     `(,entry ,entry)
				     entry))
			accessors)
       ,object
     ,@body))

(defparameter *my-special-variable* "xyz")

(cl:defpackage #:ralexandria.prog.renaming-test-isolated
  (:local-nicknames (#:p #:ralexandria.prog.renaming)))

(in-package #:ralexandria.prog.renaming-test-isolated)

(cl:defun test-renaming-macros-2 ()
  "tests that it works in packages that don't import '&body"
  (cl:assert
   (cl:=
    (cl:progn
      (p:renaming (:macro) ((ralexandria.prog.renaming-test:my-with-accessors with-accessors-clone)))
      (cl:eval
       `(with-accessors-clone (cl:car) (cl:list 1 2)
          cl:car)))
    1)))

(cl:defun test-renaming-symbols ()
  (cl:assert
   (cl:string=
    (cl:progn
      (p:renaming (:symbol) ((ralexandria.prog.renaming-test:*my-special-variable* var)))
      (cl:eval 'var))
  "xyz")))
