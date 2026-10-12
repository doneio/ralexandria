(defpackage #:ralexandria.macros.with-accessors
  (:export #:with-accessors
           #:s))

(defpackage #:ralexandria.macros.with-accessors-impl
  (:use :cl)
  (:local-nicknames (#:p #:ralexandria.macros.with-accessors)))
