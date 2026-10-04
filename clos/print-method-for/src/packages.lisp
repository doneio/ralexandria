(defpackage #:ralexandria.clos.print-method-for
  (:use)
  (:export #:call-print-method-for #:print-method-for))

(defpackage #:ralexandria.clos.print-method-for-impl
  (:use :cl)
  (:local-nicknames (#:p #:ralexandria.clos.print-method-for)))
