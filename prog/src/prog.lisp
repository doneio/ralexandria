(in-package #:ralexandria.prog-impl)

(define-modify-macro prog:toggle () not) ; automatically handles complex "places" (like array indices or nested slots) and prevents double evaluation bugs, unlike the version from the book On Lisp. (setf (aref my-array (incf i)) (not (aref my-array (incf i)))). The index i is incremented twice, which is almost certainly a bug. Using the modify macro: It calculates the "address" of the place once, reads the value, negates it, and stores it back. i is incremented only once.

(defmacro prog:string-case (string-form &body clauses)
  "A case-like macro for strings. Works like CASE but uses STRING=."
  (let ((tmp-string (gensym "STRING")))
    `(let ((,tmp-string ,string-form))
       (cond
         ,@(loop for clause in clauses
                 for (key . body) = clause
                 collect
                 (cond
                   ;; Handle (t ...) or (otherwise ...) as default
                   ((member key '(t otherwise))
                    `(t ,@body))
                   ;; Handle (( "a" "b" ) ...)
                   ((listp key)
                    `((or ,@(mapcar (lambda (k) `(string= ,tmp-string ,k)) key))
                      ,@body))
                   ;; Handle ( "a" ...)
                   (t
                    `((string= ,tmp-string ,key) ,@body))))))))
