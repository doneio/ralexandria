(defpackage #:ralexandria.prog.advice.symbol-export
  (:use #:cl)
  (:local-nicknames (#:a #:ralexandria.advice)))

(in-package #:ralexandria.prog.advice.symbol-export)

#+(and swank sbcl)
(a:defadvices ((cl:read cl:load) maybe-export-undefined-symbol :around) (&rest args)
  (let (the-symbol the-package)
    (restart-case
        (let ((fn (lambda (c &aux (str (format nil "~A" c)))
                    (cl-ppcre:register-groups-bind (symb package)
                        ("ymbol \"(.+)\".+in the (.+) package." str)
                      (setf the-symbol symb
                            the-package package)
                      #+c(break "~A:~A" the-package the-symbol)
                      #+c(invoke-restart 'export-and-retry)
                      ))))
          (handler-bind ((SB-C::INPUT-ERROR-IN-LOAD fn)
                         (SB-INT:SIMPLE-READER-PACKAGE-ERROR fn))
            (apply #'a:call-next-advice args)))
      (export-and-retry ()
        #+c(swank:export-symbol-for-emacs the-symbol the-package)
        (when (symbolp the-symbol)
          (setf the-symbol (symbol-name the-symbol)))
        (when (symbolp the-package)
          (setf the-package (symbol-name the-package)))
        (swank:eval-in-emacs `(slime-frob-defpackage-form ,the-package :export ,the-symbol))
        (swank:export-symbol-for-emacs the-symbol
                                       the-package)
        (apply #'a:call-function args)))))
