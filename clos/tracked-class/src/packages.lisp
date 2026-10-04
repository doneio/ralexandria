(defpackage #:ralexandria.clos.tracked-class
  (:use)
  (:export
   #:*object-versions*
   #:tracked-class
   #:object-version
   #:increase-version
   #:ensure-tracked))

(defpackage #:ralexandria.clos.tracked-class-impl
  (:use :cl)
  (:local-nicknames (#:p #:ralexandria.clos.tracked-class)
                    (#:mop #:closer-mop)))
