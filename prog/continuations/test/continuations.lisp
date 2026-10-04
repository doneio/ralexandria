(in-package #:ralexandria.prog.continuations-test)

(c:=defun inc (n)
  (c:=values (1+ n)))

(defun do-tests ()
  (assert (eql 1
               (c:=bind (x) (c:=values 1)
                 x)))
  (assert (eql 13 (c:=bind (x) (c:=values 3)
                    (+ x 10))))

  (assert (eql 3 (c:=bind (x) (c:=values 1)
                    (c:=bind (y) (c:=values 2)
                      (+ x y)))))

  ;; =defun: NAME becomes a macro that threads *cont* as the first argument.
  (assert (eql 6 (c:=bind (r) (inc 5) r)))

  ;; =labels: mutual recursion (even?/odd?) within a single form.
  (assert (eq t (c:=labels
                    ((my-even (n) (if (zerop n) (c:=values t) (my-odd (1- n))))
                     (my-odd  (n) (if (zerop n) (c:=values nil) (my-even (1- n)))))
                  (c:=bind (r) (my-even 10) r))))
  (assert (eq nil (c:=labels
                       ((my-even (n) (if (zerop n) (c:=values t) (my-odd (1- n))))
                        (my-odd  (n) (if (zerop n) (c:=values nil) (my-even (1- n)))))
                     (c:=bind (r) (my-odd 8) r))))

  ;; =funcall: call an =lambda (which takes *cont* as its first arg) with ARGS.
  (assert (eql 42 (c:=funcall
                      (c:=lambda (a) (c:=values (* a 2))) 21)))

  ;; =apply: mirrors cl:apply — the last argument is a list.
  (assert (eql 3 (c:=apply
                     (c:=lambda (a b) (c:=values (+ a b))) 1 '(2))))

  (run-coroutine-test)
  (run-resume-test)

  (format t "ralexandria.prog.continuations: all tests passed.~%"))

(defvar *dft-saved* nil)
(defvar *dft-result* nil)

(c:=defun re-start ()
  (if *dft-saved*
      (funcall (pop *dft-saved*))
      (c:=values 'done)))

(c:=defun dft-node (tree)
  (cond ((null tree) (re-start))
        ((atom tree) (c:=values tree))
        (t (push (lambda ()
                   (dft-node (cdr tree)))
                 *dft-saved*) 
           (dft-node (car tree)))))

(defun collect-dft (tree)
  "Depth-first traverse TREE via the CPS coroutine, returning the list of
atoms in visitation order."
  (let ((*dft-saved* nil)
        (*dft-result* nil))
    (c:=bind (node) (dft-node tree)
      (if (eq node 'done)
          'done
          (progn (push node *dft-result*)
                 (re-start))))
    (nreverse *dft-result*)))

(defun run-coroutine-test ()
  "coroutine: depth-first traversal via continuations."
  (let ((t1 '(a (b (d h)) (c e (f i) g))))
    (assert (equal '(a b d h c e f i g)
                   (collect-dft t1))))
  (let ((t2 '(1 (2 (3 6 7) 4 5))))
    (assert (equal '(1 2 3 6 7 4 5)
                   (collect-dft t2))))
  (assert (equal '(z) (collect-dft 'z)))
  (assert (equal '() (collect-dft '()))))

(defvar *saved-thunk* nil)

(c:=defun save-thunk (msg)
  (setf *saved-thunk*
        (lambda ()
          (c:=values (format nil "Resumed: ~A" msg)))))

(defun run-resume-test ()
  (setf *saved-thunk* nil)
  (let ((ran nil))
    (c:=bind (result) (save-thunk "Secret Data")
      (format t "Final output inside loop: ~A~%" result)
      (setf ran result))
    ;; =bind has returned; the continuation was captured but NOT yet invoked,
    ;; so the body has not run yet.
    (assert (null ran))
    (assert (not (null *saved-thunk*)))
    (format t "Attempting to resume saved thunk...~%")
    (funcall *saved-thunk*)                  ; resume -> runs the =bind body now
    (assert (string= "Resumed: Secret Data" ran))
    ran))

