(defpackage #:ralexandria.clos
  (:use)
  (:export #:class-inherited-by-p))

(defpackage #:ralexandria.clos-impl
  (:use :cl)
  (:local-nicknames (#:clos #:ralexandria.clos)))
