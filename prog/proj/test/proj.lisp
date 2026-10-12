(cl:in-package #:ralexandria.prog.proj-test)

(defun read-forms-from-file (pathname)
  "Reads all Common Lisp forms from PATHNAME and returns them as a list."
  (with-open-file (stream pathname :direction :input)
    ;; Create a unique sentinel object to detect EOF reliably
    (let ((eof-marker (gensym)))
      (loop :for form = (read stream nil eof-marker)
            :until (eq form eof-marker)
            :collect form))))


(defvar *do-once* ; we define this package to avoid errors in the test
    (cl:defpackage #:tmp.accounting.module1_-test ; when tmp.accounting.module1_-test:do-tests is read
      (:use)
      (:export #:do-tests)))

(defun do-tests ()
  (let* ((name "tmp.accounting.module1_")
         (short-name "module1_")
         (proj-path
           (proj:new-project (uiop:temporary-directory)
                             :name name
                             :short-name short-name)))
    (flet ((check (directory name type contents)
             (assert (my-equalp
                      (read-forms-from-file
                       (make-pathname
                        :name name
                        :type type
                        :defaults (merge-pathnames directory proj-path)))
                      contents))))
      (check #p"" name "asd"
'((in-package #:asdf-user)
  (defsystem #:tmp.accounting.module1_
   :name ""
   :pathname "src"
   :depends-on ()
   :components ((:file "packages")
                (:file "module1_"))
   :in-order-to ((test-op (test-op "tmp.accounting.module1_-test"))))))
      (check #p"src/" short-name "lisp" 
'((in-package #:tmp.accounting.module1_-impl)))
      (check #p"src/" "packages" "lisp"
 '((defpackage #:tmp.accounting.module1_
                 (:use)
    (:export ))

  (defpackage #:tmp.accounting.module1_-impl
    (:use :cl)
    (:local-nicknames (#:module1_ #:tmp.accounting.module1_)))))
      (check #p"test/" (strings:+ name "-test") "asd"
'((in-package #:asdf-user)
  (defsystem #:tmp.accounting.module1_-test
    :name ""
    :depends-on (#:tmp.accounting.module1_)
    :components ((:file "packages")
                 (:file "module1_"))
    :perform (test-op (operation component)
                      (uiop:symbol-call 'tmp.accounting.module1_-test 'do-tests)))))
      (check #p"test/" short-name "lisp"
'((in-package #:tmp.accounting.module1_-impl)
  (defun tmp.accounting.module1_-test:do-tests ()
    (princ "tmp.accounting.module1_: all tests passed.")(terpri))))
      (check #p"test/" "packages" "lisp" 
'((cl:defpackage #:tmp.accounting.module1_-test
    (:use)
    (:export #:do-tests))))))
  (format t "ralexandria.prog.proj all tests passed.~%"))

(defun my-equalp (list1 list2)
  "custom comparison function that compares symbols by their symbol-name string rather than their absolute object identity in memory so that leafs which are uninterned symbols are considered equal if they have the same name"
  (tree-equal list1 list2 
            :test (lambda (x y)
                    (if (and (symbolp x) (symbolp y))
                        (string= (symbol-name x) (symbol-name y))
                        (equalp x y)))))
