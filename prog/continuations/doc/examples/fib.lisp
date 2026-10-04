;;; just a toy example, perhaps not the most beautiful.

(defpackage #:fib-generator
  (:export #:=yield
           #:next-val
           #:resume-cont
           #:make-fibo-generator
           #:run-generator-demo))

(defpackage #:fib-generator-impl
  (:use #:common-lisp)
  (:local-nicknames (#:gen #:fib-generator)
                    (#:c #:ralexandria.prog.continuations)))

(in-package #:fib-generator-impl)

(defclass gen-state ()
  ((resume-cont :initarg :resume-cont :accessor gen:resume-cont)))

(defmacro yield (state value)
  `(progn
     (setf (gen:resume-cont ,state) c:*cont*)
     ,value))

(defun gen:next-val (generator)
  (funcall (gen:resume-cont generator)
             c:*actual-cont*))

(defun gen:make-fibo-generator ()
  (let ((state (make-instance 'gen-state)))
    (setf (gen:resume-cont state)
          (c:=lambda ()
            (labels ((iter (a b)
                       (c:=bind (_) (gen:=yield state a)
                         (iter b (+ a b)))))
              (iter 0 1))))
    state)) 

(defun gen:run-generator-demo ()
  (let ((my-gen (gen:make-fibo-generator)))
    (loop :repeat 8 :collect (gen:next-val my-gen))))

(assert (equalp
         (gen:run-generator-demo)
         '(0 1 1 2 3 5 8 13)))
