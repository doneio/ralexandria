(in-package #:ralexandria.prog.proj-impl)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defvar *original-readtable* (copy-readtable))
  (set-dispatch-macro-character #\# #\> #'multiline-string:reader))

(defclass project-specification ()
  ((name :initarg :name :accessor proj:name)
   (short-name :initarg :short-name :accessor proj:short-name)
   (depends-on :initarg :depends-on :accessor proj:depends-on :initform (proj:make-depends-on))
   (interface-package :initarg :interface-package :accessor proj:interface-package :initform nil)
   (test-dir :initarg :test-dir :accessor proj:test-dir :initform nil)
   (local-nicknames :initarg :local-nicknames :accessor proj:local-nicknames :initform (proj:make-local-nicknames))
   (load-packages :initarg :load-packages :accessor proj:load-packages)))

(defun proj:make-depends-on ()
  '())

(defun proj:make-local-nicknames (&optional (local-nicknames '()))
  (cond
    ((null local-nicknames) '())
    ((and (consp local-nicknames)
          (consp (car local-nicknames)))
     local-nicknames)
    (t (list local-nicknames))))

(defun proj:make-local-nickname (nickname package-name)
  (list (make-symbol (string-upcase nickname))
        (make-symbol (string-upcase package-name))))

(defun proj:nickname (local-nickname)
  (first local-nickname))

(defun proj:package-name (local-nickname)
  (second local-nickname))

(defun proj:local-nicknames-default-value-p (value)
  (null value))

(defun proj:local-nicknames-string (local-nicknames)
  (if (proj:local-nicknames-default-value-p local-nicknames)
      ""
      (format nil "~%(:local-nicknames ~{~A~^~%~})"
              (mapcar (lambda (obj)
                        (format nil "(#:~A #:~A)"
                                (string-downcase (proj:nickname obj))
                                (string-downcase (proj:package-name obj))))
                      local-nicknames))))

(defun dir-from (dir)
  (assert (not (char= #\/ (aref dir (1- (length dir))))))
  (strings:+ dir "/"))

(defvar *spec*)

(defvar *name*)
(defvar *short-name*)

(defgeneric create-dir (type path))
(defmethod create-dir :around (type path)
  (ensure-directories-exist path)
  (with-accessors ((name proj:name)
                   (short-name proj:short-name)) *spec*
    (let ((*name* name)
          (*short-name* short-name))
      (call-next-method))))

(defmacro with-open-file% ((stream path) &body body)
  `(with-open-file (,stream ,path :direction :output :if-exists :supersede)
     ,@body))

(defmethod create-dir ((type (eql :proj)) path)
  "Create the files in the project directory"
  (with-open-file% (stream (merge-pathnames (strings:+ *name* ".asd") path))
(let ((*print-gensym* t)
      (*print-case* :downcase))
    (format stream #>END"
(in-package #:asdf-user)

(defsystem #:~A
  :name ""
  :pathname "src"
  :depends-on ~S
  :components ((:file "packages")
               (:file "~A"))
  ~A)
END" *name* (proj:depends-on *spec*) *short-name*
     (if (proj:test-dir *spec*)
         (format nil ":in-order-to ((test-op (test-op \"~A-test\")))" *name*)
         "")))))

(defmethod create-dir ((type (eql :src)) path)
  "Create the files in the src directory"
  (let ((packages-lisp-file (merge-pathnames "packages.lisp" path)))
    (with-open-file% (stream packages-lisp-file)
      (let ((interface-package-string
              (format stream "(defpackage #:~A
  (:use)
  (:export ))
" *name*)))
        (format stream "~A(defpackage #:~A-impl
  (:use :cl)~A)
" (if (proj:interface-package *spec*)
      interface-package-string
      "")
                *name*
                (proj:local-nicknames-string (proj:local-nicknames *spec*)))))
    (when (proj:load-packages *spec*)
      (load packages-lisp-file)))
  (with-open-file% (stream (merge-pathnames (strings:+ *short-name* ".lisp") path))
    (format stream "(in-package #:~A-impl)~%" *name*)))

(defmethod create-dir ((type (eql :test)) path)
  (with-open-file% (stream (merge-pathnames (strings:+ *name* "-test.asd") path))
    (format stream #>END"
(in-package #:asdf-user)

(defsystem #:~A-test
  :name ""
  :depends-on (#:~A)
  :components ((:file "packages")
               (:file "~A"))
  :perform (test-op (operation component)
              (uiop:symbol-call '~A-test 'do-tests)))
END" *name* *name* *short-name* *name*))
  (let ((packages-lisp-file (merge-pathnames "packages.lisp" path)))
    (with-open-file% (stream packages-lisp-file)
      (format stream #>END"
(cl:defpackage #:~A-test
  (:use)
  (:export #:do-tests))
END"                       ; (#:~A-impl #:~A-impl) *short-name* *name*
              *name*))
    (when (proj:load-packages *spec*)
      (load packages-lisp-file)))
  (with-open-file% (stream (merge-pathnames (strings:+ *short-name* ".lisp") path))
    (format stream #>END"
(in-package #:~A-impl)

(defun ~A-test:do-tests ()
  (princ "~A: all tests passed.")(terpri))
END" *name* *name* *name*)))

(defun proj:new-project (path &key name (short-name name) depends-on (local-nicknames (proj:make-local-nicknames))
   (interface-package t)
                                (test-dir t)
                                (load-packages t))
  (declare (ignorable depends-on local-nicknames))
  (when interface-package
    (setf local-nicknames
          (proj:make-local-nicknames (proj:make-local-nickname short-name name))))
  (let* ((proj-path (merge-pathnames (dir-from short-name) path))
         (src-path (merge-pathnames "src/" proj-path))
         (test-path (merge-pathnames "test/" proj-path))
         (*spec* (make-instance 'project-specification
                                :name name
                                :short-name short-name
                                :depends-on depends-on
                                :test-dir test-dir
                                :local-nicknames local-nicknames
                                :load-packages load-packages)))
    (create-dir :proj proj-path)
    (create-dir :src src-path)
    (when test-dir
      (create-dir :test test-path))
    (values proj-path src-path test-path)))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (setf *readtable* *original-readtable*))
