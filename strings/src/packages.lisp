(defpackage #:ralexandria.strings
  (:use)
  (:export
   #:+
   #:*diacritics*
   #:diacritics-to-ascii
   #:diacritics=
   #:mapconcat
   #:stringify
   #:*random-CHARSET*
   #:RANDOM-STRING
   #:ENSURE-STRING))

(defpackage #:ralexandria.strings-impl
  (:use :cl)
  (:local-nicknames (#:strings #:ralexandria.strings)))
