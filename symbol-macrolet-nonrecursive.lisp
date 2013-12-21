;;;; symbol-macrolet-nonrecursive.lisp
;;;; Copyright (c) 2013 Robert Smith

;;; Single binding example for the general idea.
#+#:ignore
(defmacro symbol-macrolet-1 ((x y) &body body)
  (let ((gx (gensym (format nil "~A-" x))))
    `(let ((,gx ,x))
       (symbol-macrolet ((,x (symbol-macrolet ((,x ,gx)) ,y)))
         ,@body))))

(defmacro symbol-macrolet-1 ((&rest macro-bindings) &body body)
  "Similar to SYMBOL-MACROLET, SYMBOL-MACROLET-1 will substitute (in an AST-aware fashion) the symbols provided in the first element of each of the MACRO-BINDINGS with the second element of each of the MACRO-BINDINGS in the body BODY. However, unlike SYMBOL-MACROLET, SYMBOL-MACROLET-1 will not perform (recursive) substitutions of itself inside of the bindings. This means that if a binding refers to itself, the same symbol must be bound in the lexical environment at runtime.

Example:

    (let ((x #(1 2 3)))
      (symbol-macrolet-1 ((x (aref x 1)))
        (list x 'x (let ((x 1)) x))))

    ==> (2 X 1)
"
  (let* ((xs (mapcar #'car macro-bindings))
         (ys (mapcar #'cadr macro-bindings))
         (gxs (mapcar (lambda (x) (gensym (format nil "~A-" x))) xs)))
    `(let (,@(mapcar #'list gxs xs))
       (symbol-macrolet (,@(mapcar (lambda (x gx y)
                                     `(,x (symbol-macrolet ((,x ,gx)) ,y)))
                                   xs gxs ys))
         ,@body))))
