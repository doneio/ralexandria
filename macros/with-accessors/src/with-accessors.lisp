(in-package #:ralexandria.macros.with-accessors-impl)

(defmacro p:with-accessors (cfg-plist pairs &body body
			       &aux fn fn-a)
  (destructuring-bind (&key (fn 'p:s fnp) (fn-a 'p:s fn-a-p)
                         (prefix '|| prefixp) (prefix-a '|| prefix-a-p)
                         (suffix '|| suffixp) (suffix-a '|| suffix-a-p)
                         (package (package-name *package*) packagep)
                         (package-a (package-name *package*) package-a-p)
                       &allow-other-keys) (if (oddp (length cfg-plist))
                                              (cons :dummy cfg-plist)
                                              cfg-plist)
    (when (every #'null (list fnp fn-a-p prefixp prefix-a-p suffixp suffix-a-p packagep package-a-p)) ; no cfg-plist
      (push pairs body)
      (setf pairs cfg-plist
            cfg-plist '()))
    (setf fn
          (compile nil `(lambda (p:s)
                               ,fn)))
    (setf fn-a
          (compile nil `(lambda (p:s)
                               ,fn-a)))
    (labels ((process (symbol prefix suffix pkg)
               #+c(break "~A" pkg)
               (intern (format nil "~A~A~A" prefix symbol suffix)
                       pkg)))
      `(cl:with-accessors ,(mapcar
                            (lambda (entry)
			      (if (consp entry)
				  entry
				  `(,(process (funcall fn-a entry) prefix-a suffix-a package-a)
                                    ,(process (funcall fn entry) prefix suffix package))))
	                    pairs)
	   ,@body))))
