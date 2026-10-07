;;; EXAMPLE

(asdf:load-system :ralexandria.prog.proj)

(ralexandria.prog.proj:new-project
 #p"./"
 :name "ralexandria.clos.tracked-class"
 :short-name "tracked-class")

;;; ANOTHER ONE
(ralexandria.prog.proj:new-project
 #p"./"
 :name "ralexandria.clos.print-method-for"
 :short-name "print-method-for")
