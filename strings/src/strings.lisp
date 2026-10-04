(in-package #:ralexandria.strings-impl)

(defun strings:ensure-string (x)
  (cond ((null x) "")
        ((stringp x) x)
        ((characterp x) (string x))
        (t (prin1-to-string x))))

(defun strings:+ (&rest args)
  (apply #'concatenate 'string
         (mapcar #'strings:ensure-string
                 args)))

(define-compiler-macro strings:+ (&rest args)
  `(concatenate 'string
    ,@(mapcar (lambda (x)
                `(strings:ensure-string ,x))
              args)))

(defparameter strings:*random-charset* "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")

(defun strings:random-string (length &optional (charset strings:*random-charset*))
  (declare (optimize (speed 3) (safety 0) (debug 0)))
  (declare (type fixnum length))
  (let* ((result (make-string length))
         (charset-len (length charset)))
    (loop for i from 0 below length
          do (setf (char result i) (char charset (random charset-len))))
    result))
