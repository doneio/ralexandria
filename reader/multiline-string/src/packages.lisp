(defpackage #:ralexandria.reader.multiline-string
  (:use)
  (:export #:reader))

(defpackage #:ralexandria.reader.multiline-string-impl
  (:use :cl)
  (:local-nicknames (#:multiline-string #:ralexandria.reader.multiline-string)))
