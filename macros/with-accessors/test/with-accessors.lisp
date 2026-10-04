(cl:in-package #:ralexandria.macros.with-accessors-test)

(defun do-tests ()
  (let ((*package* #.*package*))
    (assert
     (equalp
      (macroexpand-1
       '(p:with-accessors (window
                           message
                           (acc accessor-function)) object
         (list window message)))
      '(WITH-ACCESSORS ((WINDOW WINDOW)
                        (MESSAGE MESSAGE)
                        (ACC ACCESSOR-FUNCTION))
        OBJECT
        (LIST WINDOW MESSAGE))))

    (assert
     (equalp
      (macroexpand-1
       '(p:with-accessors (:package-a :ralexandria.macros.with-accessors-test
                           :package "CL-USER"
                           :prefix-a o-
                           :prefix f-
                           :suffix-a %
                           :suffix $
                           :fn-a (intern (string-downcase (symbol-name p:s)))
                           :fn (intern (concatenate 'string (symbol-name p:s) "_")))
         (window
          message
          (acc accessor-function)) object
         (list o-window
          o-message)))
      '(WITH-ACCESSORS ((|O-window%| COMMON-LISP-USER::F-WINDOW_$)
                        (|O-message%| COMMON-LISP-USER::F-MESSAGE_$)
                        (ACC ACCESSOR-FUNCTION))
        OBJECT
        (LIST O-WINDOW O-MESSAGE)))))
  (format t "ralexandria.macros.with-accessors all tests passed.~%"))
