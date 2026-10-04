(defvar *original-readtable* (copy-readtable))
(set-dispatch-macro-character #\# #\> #'ralexandria.reader.multiline-string:reader)
;;; code that uses the reader
#>END"
abcEND" ; select and c-R [eval region] in emacs
;;; end code that uses the reader
(setf *readtable* *original-readtable*)

