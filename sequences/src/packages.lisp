(defpackage #:ralexandria.sequences
  (:export
   #:push-end
   #:subseq2
   #:ensure-list
   #:group
   #:flatten
   #:getf*
   #:all-elements-different-p
   #:remove-plist-properties))

(defpackage #:ralexandria.sequences-impl
  (:use :cl)
  (:local-nicknames (#:s #:ralexandria.sequences)))
