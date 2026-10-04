(cl:in-package #:ralexandria.macros-test)

(defun do-tests ()
  (test-with-gensyms)
  (test-once-only)
  (format t "ralexandria.macros all tests passed.~%"))

(defun test-with-gensyms ()
  (let ((expansion (macroexpand-1 '(macros:with-gensyms (x y)
                                    (list x y)))))
    (assert (eq (first expansion) 'let))
   
    (let ((bindings (second expansion))
          (body     (cddr expansion)))
      
      (assert (= (length bindings) 2))
      
      (let ((binding-1 (first bindings))
            (binding-2 (second bindings)))
        
        ;; Verify the binding variables match your requested symbols
        (assert (eq (first binding-1) 'x))
        (assert (eq (first binding-2) 'y))
        
        ;; Verify they call gensym logic (usually containing GENSYM or MAKE-SYMBOL)
        (assert (member (first (second binding-1)) '(gensym make-symbol)))
        (assert (member (first (second binding-2)) '(gensym make-symbol))))
      ;; Verify the body remains untouched
      (assert (equal body '((list x y)))))))

(defun test-once-only ()
  ;; 1. Define the macro behavior at runtime
  (let* ((macro-fn (compile nil ; we use compile basically to eval the
                            '(lambda (form env) ; macroexpansion of once-only
                               (declare (ignore env))
                               (let ((x (second form)))
                                 (macros:once-only (x)
                                   `(* ,x ,x))))))
         
         ;; 2. Expand: (square (foo))
         (expansion (funcall macro-fn '(square (foo)) nil)))
    
    ;; The expansion is now completely pure code:
    ;; (LET ((#:G123 (FOO))) (* #:G123 #:G123))
    
    ;; Assert top level is a standard LET
    (assert (eq (first expansion) 'let))
    
    (let* ((bindings (second expansion))
           (body     (cddr expansion))
           (binding  (first bindings))
           (gensym-var (first binding))
           (bound-expr (second binding)))
      
      ;; Assert it binds exactly 1 variable
      (assert (= (length bindings) 1))
      
      ;; Assert that the variable is bound to the target expression: (FOO)
      (assert (equal bound-expr '(foo)))
      
      ;; Assert that the variable is an uninterned symbol (a true gensym)
      (assert (null (symbol-package gensym-var)))
      
      ;; Assert the body expression computes: (* GENSYM GENSYM)
      (assert (equal body `((* ,gensym-var ,gensym-var)))))))
