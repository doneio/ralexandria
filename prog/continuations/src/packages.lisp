(defpackage #:ralexandria.prog.continuations
  (:export
   #:*cont*
   #:*actual-cont*
   #:=defun
   #:=labels
   #:=bind
   #:=values
   #:=funcall
   #:=apply
   #:*k*
   #:k->url
   #:url->k
   #:continuations-route
   #:=LAMBDA))

(defpackage #:ralexandria.prog.continuations-impl
  (:use :cl)
  (:local-nicknames (#:continuations #:ralexandria.prog.continuations)
                    (#:strings #:ralexandria.strings)))
