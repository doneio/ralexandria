(cl:in-package #:ralexandria.prog.advice-test)

(defun do-tests ()
  (defadvice-test-1)#|
  (defadvice-test-2)
  (remove-advice-test-1)
  (remove-advice-test-2)
  (interfering-advice-tests-1)
  (interfering-advice-tests-2)
  (updating-advice-tests-1)
  (updating-advice-tests-2)
  (macro-advice-tests)
  (with-advice-test)|#
  )

;; (do-tests)
(defun defadvice-test-1 ()
  (defun sum (values)
    (reduce #'+ values))

  (defun do-sum ()
    (sum '(1 3 5)))

  (a:defadvice (sum add-mean :around) (nums)
    (let ((result (a:call-next-advice nums)))
      (values result
              (/ result (length nums)))))
  (assert
   (equal '(9 3)
          (multiple-value-list
           (do-sum)))))

(defun defadvice-test-2 ()
  (a:defadvice (sum add-mean2 :around) (nums)
    (multiple-value-bind (v1 v2) (funcall #'a:call-next-advice nums)
      (values v1 v2 :v3)))
  (assert
   (equal '(9 3 :v3)
          (multiple-value-list
           (do-sum)))))

(defun remove-advice-test-1 ()
  (a:remove-advice 'sum 'add-mean2)
  (assert
   (equal '(9 3)
          (multiple-value-list
           (do-sum)))))

(defun remove-advice-test-2 ()
  (a:remove-advice 'sum 'add-mean)
  (assert (= 9 (do-sum))))

#+c(defun single-advice-tests ()
  (a:defadvice-test1)
  (a:defadvice-test2)
  (a:remove-advice-test-1)
  (a:remove-advice-test-2))

(defun interfering-advice-tests-1 ()
  (defun sum (args)
    (apply #'+ args))
  (a:defadvice (sum add-mean :around) (nums)
    (let ((result (a:call-next-advice nums)))
      (values result
              (/ result (length nums)))))
  (a:defadvice (sum add-mean2 :around) (nums)
    (progn
      (print "sum here")
      (a:call-next-advice nums)))
  
  (defun sum% (args)
    (apply #'+ args))
  (a:defadvice (sum% add-mean :around) (nums)
    (let ((result (a:call-next-advice nums)))
      (values result -1)))
  (a:defadvice (sum% add-mean2 :around) (nums)
    (progn
      (print "sum% here")
      (a:call-next-advice nums)))

  (defun nop1 ())
  (defun nop2 ())
  (a:defadvice (nop1 add-mean :around) ()
    (a:call-next-advice)
    :nop1)
  (a:defadvice (nop2 add-mean :around) ()
    :nop2)
  (assert
   (equal '(9 3)
          (multiple-value-list
           (do-sum)))))

(defun interfering-advice-tests-2 ()
  (assert
   (equal '(5 -1)
          (multiple-value-list
           (sum% '(2 3))))))

(defun updating-advice-tests-1 ()
  (defun op (&rest args)
    (apply #'+ args))
  (a:defadvice (op minus :around) (&rest args)
    (apply #'- args))
  (assert (= 1 (op 3 2))))
  
(defun updating-advice-tests-2 ()
  ;; we update the :minus :around advice to do multiplication instead of -.
  (a:defadvice (op minus :around) (&rest args)
    (apply #'* args))
  (assert (= 6 (op 3 2))))

(defun macro-advice-tests ()
  (defmacro m1 (&body body)
    `(2 3 ,@body))
  (a:defadvice (m1 add-operation :around) (whole env)
    (let ((result (apply #'a:call-next-advice (list whole env))))	   
      (cons '+ result)))
  (assert
   (equalp '(+ 2 3 4 5)
           (nth-value 0 (macroexpand-1 `(m1 4 5))))))

(defun with-advice-test ()
  (defun sum%% (args)
    (apply #'+ args))
  (a:with-advice (sum%% add-mean :around) (nums)
    (let ((result (a:call-next-advice nums)))
      (values result
	      (/ result (length nums))))
    (assert
     (equal '(5 5/2)
            (multiple-value-list
             (sum%% '(2 3)))))))
