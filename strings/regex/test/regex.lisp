(in-package #:ralexandria.strings.regex-test)

(defun do-tests ()
  (test-scan-to-string)
  (test-lambda-matches)
  (format t "ralexandria.strings.regex all tests passed.~%"))

(defun test-scan-to-string ()
  (assert
   (string= (regex:scan-to-string "<h1>(.*?)</h1>"
                                  "<h1>Welcome to Common Lisp</h1>")
            "Welcome to Common Lisp")))

(defun test-lambda-matches ()
  (assert
   (string=
    (format-product-codes "Item A is id-123 and Item B is id-999.")
    "Item A is [PRODUCT #123] and Item B is [PRODUCT #999].")))

(defun format-product-codes (text)
  (cl-ppcre:regex-replace-all 
   "id-(\\d+)"
   text
   (regex:lambda-matches (whole-string &part matched-part &matches digits)
     (declare (ignore matched-part))
     ;; whole-string contains the entire string
     ;; matched-part contains strings like "id-123"
     ;; digits' contains just the captured group digits like "123"
     
     ;; Return the replacement string for this specific match
     (format nil "[PRODUCT #~A]" digits))))
