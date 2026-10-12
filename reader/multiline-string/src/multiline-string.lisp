(cl:in-package #:ralexandria.reader.multiline-string-impl)

(defun multiline-string:reader (stream sub-char numarg)
  (declare (ignore sub-char numarg))
  (let ((chars '()))
    (do ((curr (read-char stream)
	       (read-char stream)))
	((char= #\newline curr))
      ;; on Windows asdf adds \r before \n
      ;; and we don't want the delimiter to contain \r or spaces or tabs
      (unless (member curr '(#\Space #\Tab #\Return))
        (push curr chars)))
    (let* ((pattern (nreverse chars))
	   (pointer pattern)
	   (output '()))
      (loop :with curr
            :do
               (setf curr (read-char stream))
	       (push curr output)
	       (setf pointer
	             (if (char= (car pointer) curr)
		         (cdr pointer)
		         pattern))
	       (when (null pointer)
	         (return)))
      (coerce
       (nreverse
	(nthcdr (length pattern) output))
       'string))))
