#|
phoe Is there a utility macro equivalent to (setf place (not place))?
beach Don't think so.  But that one could be worthwhile so as to avoid multiple evaluation of the sub-forms of the place.
phoe I ask because (setf (left-now-p (walk-parent shape)) (not (left-now-p (walk-parent shape)))) is pretty long for me.
phoe Also what you just said.
beach Especially what I just said! :)
|#
