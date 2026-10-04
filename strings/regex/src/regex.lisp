(in-package #:ralexandria.strings.regex-impl)

(defun regex:scan-to-string (regexp str)
  (multiple-value-bind (ret-all groups) (cl-ppcre:scan-to-strings regexp str)
    (unless (null ret-all)
      (aref groups 0))))

(defun nth-reg (n str reg-starts reg-ends)
  (subseq str (aref reg-starts n)
          (aref reg-ends n)))

(defmacro regex:lambda-matches ((str &part str-part &matches &rest matches) &body body)
  "Used to generate a lambda for cl-ppcre:regex-replace-all. See documentation."
  (declare (ignore &part &matches))
  (macros:with-gensyms (start end match-start match-end reg-starts reg-ends)
    `(lambda (,str ,start ,end ,match-start ,match-end ,reg-starts ,reg-ends)
       (declare (ignorable ,str ,start ,end ,match-start ,match-end ,reg-starts ,reg-ends))
       (let ((,str-part (subseq ,str ,match-start ,match-end))
             ,@(loop :for match :in matches
                    :for i :from 0
                    :collect
                    (destructuring-bind (var) (uiop:ensure-list match)
                      `(,var (nth-reg ,i ,str ,reg-starts ,reg-ends)))))
         ,@body))))
