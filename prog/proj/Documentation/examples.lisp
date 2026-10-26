;;; EXAMPLES

(asdf:load-system :ralexandria.prog.proj)

(ralexandria.prog.proj:new-project
 #p"./"
 :name "ralexandria.clos.tracked-class"
 :short-name "tracked-class")

(ralexandria.prog.proj:new-project
 #p"./"
 :name "ralexandria.clos.print-method-for"
 :short-name "print-method-for")

(ralexandria.prog.proj:new-project
 "./alexandria/alexandria-2/"
 :name "alexandria-2.arrays"
 :short-name "arrays"
 :depends-on '(#:alexandria-packages)
 :test-dir t
 :interface-package nil
 ;; :local-nicknames '() 
 )
