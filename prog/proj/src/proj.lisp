(in-package #:ralexandria.prog.proj-impl)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defvar *original-readtable* (copy-readtable))
  (set-dispatch-macro-character #\# #\> #'multiline-string:reader))

(defclass project-specification ()
  ((name :initarg :name :accessor proj:name)
   (short-name :initarg :short-name :accessor proj:short-name)
   (depends-on :initarg :depends-on :accessor proj:depends-on :initform (make-depends-on))))

(defun make-depends-on ()
  '())

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
     (flet ((wr (object &rest args)
              (apply #'write object :stream ,stream args)))
       (declare (ignorable (function wr)))
       (let ((*print-case* :downcase)
             (*print-escape* nil))
         ,@body))))

(defmethod create-dir ((type (eql :proj)) path)
  "Create the files in the project directory"
  (with-open-file% (stream (merge-pathnames (strings:+ *name* ".asd") path))
    (wr '(in-package #:asdf-user))
    (terpri stream)(terpri stream)
    #+TODO(let ((*package* (find-package :asdf-user))))
    (wr `(defsystem ,(make-symbol (string-upcase *name*))
           :name ""
           :pathname "src"
           :depends-on ()
           :components ((:file "packages")
                        (:file ,*short-name*)
                        :in-order-to ((test-op (test-op ,(strings:+ *name* "-test"))))))))))

(defmethod create-dir ((type (eql :src)) path)
  "Create the files in the src directory"
    (with-open-file% (stream (merge-pathnames "packages.lisp" path))
      (format stream #>END"
(defpackage #:~A
  (:use)
  (:export ))

(defpackage #:~A-impl
  (:use :cl)
  (:local-nicknames (#:~A #:~A)))
END" *name* *name* *short-name* *name*))
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
  (with-open-file% (stream (merge-pathnames "packages.lisp" path))
    (format stream #>END"
(cl:defpackage #:~A-test
  (:use)
  (:export #:do-tests))
END" ; (#:~A-impl #:~A-impl) *short-name* *name*
            *name*))
  (with-open-file% (stream (merge-pathnames (strings:+ *short-name* ".lisp") path))
    (format stream #>END"
(in-package #:~A-impl)

(defun ~A-test:do-tests ()
  (princ "~A: all tests passed.")(terpri))
END" *name* *name* *name*)))

(defun proj:new-project (path &rest keys &key name (short-name name) depends-on)
  (declare (ignorable depends-on))
  (let* ((proj-path (merge-pathnames (dir-from short-name) path))
         (src-path (merge-pathnames "src/" proj-path))
         (test-path (merge-pathnames "test/" proj-path))
         (*spec* (apply #'make-instance 'project-specification keys)))
    (create-dir :proj proj-path)
    (create-dir :src src-path)
    (create-dir :test test-path)
    (values proj-path src-path test-path)))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (setf *readtable* *original-readtable*))
