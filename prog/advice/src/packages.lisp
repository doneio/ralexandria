(defpackage #:ralexandria.prog.advice
  (:export
   #:*advised-functions*
   #:get-around-advices
   #:defadvice
   #:call-next-advice
   #:remove-advice
   #:with-advice
   #:defadvices
   #:remove-advices
   #:rdefadvice
   #:RDEFADVICES
   #:CALL-FUNCTION
   #:*ADVISORS*
   #:GET-ADVISOR))

(defpackage #:ralexandria.prog.advice-impl
  (:use :cl)
  (:local-nicknames (#:a #:ralexandria.prog.advice)))
