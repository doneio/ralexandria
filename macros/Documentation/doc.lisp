#|
ralexandria.macros.with-accessors is a separate module because many apps don't need it

|#

(ralexandria.prog.renaming:renaming (:generic :method :function :macro)
          (ralexandria.macros.with-accessors:with-accessors)
          :to-package yourapp.macros)
