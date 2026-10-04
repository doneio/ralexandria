(in-package #:ralexandria.sequences-impl)

(defmacro s:push-end (object place)
  `(setf ,place (nconc ,place (list ,object))))

(defun s:subseq2 (seq start &optional end &aux (len (length seq)))
  (if (not (null end))
      (when (< end 0)
        (setf end (+ len end)))
    (setf end len))
  (when (< start 0)
    (setf start (+ len start)))
  (subseq seq start end))

(defun s:ensure-list (object)
  (if (consp object)
      object
      (list object)))

(defun s:group (source n)
    (if (zerop n) (error "zero length"))
    (labels ((rec (source acc)
	       (let ((rest (nthcdr n source)))
		 (if (consp rest)
		     (rec rest (cons
				(subseq source 0 n)
				acc))
		     (nreverse
		      (cons source acc))))))
      (if source (rec source nil) nil)))
  
(defun s:flatten (x)
    (labels ((flat (x acc)
	       (cond ((null x) acc)
;;;		     #+sbcl ((typep x 'sb-impl::comma) (flat (sb-impl::comma-expr x) acc))
		     ((atom x) (cons x acc))
		     (t (flat (car x) (flat (cdr x) acc))))
	       ))
      (flat x nil)))

(defmacro s:getf* (obj keys)
  "deep access into plists"
  (if (= 1 (length (setf keys
                         (s:ensure-list keys))))
      `(getf ,obj ,(first keys))
      `(s:getf* (getf ,obj ,(first keys))
	      ,(rest keys))))

(defun s:all-elements-different-p (lst &key (test #'equal))
  (do ((lst lst (cdr lst)))
    ((or (null lst)
	 (find (first lst) (cdr lst) :test test))
     (null lst))))

(defun s:remove-plist-properties (plist properties)
  (loop :for (key val) :on plist :by #'cddr
        :unless (find key properties)
          :append (list key val)))
