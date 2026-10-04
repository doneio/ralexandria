(defpackage #:ralexandria.strings.regex
  (:use)
  (:export
   #:scan-to-string
   #:lambda-matches))

(defpackage #:ralexandria.strings.regex-impl
  (:use :cl)
  (:local-nicknames (#:regex #:ralexandria.strings.regex)
                    (#:macros #:ralexandria.macros)))
