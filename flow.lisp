;;;; flow.lisp
;;;;
;;;; Copyright (c) 2014 Robert Smith

;;;; Postfix composition of expressions.


;;;; TODO: Multiple-value FLOW macro.

(defmacro flow (expr &rest slotted-exprs)
  "Evaluate EXPR, and pass it to the next slotted expression, which itself gets evaluated.

A \"slotted expression\" is an expression which possibly contains the symbol `$' as a free variable. The symbol will be bound to the value previous to the slotted expression before it is evaluated.

For example, the flow expression

    (flow 5
          (+ 2 $)
          (- 4 $)
          (* $ $))

will be evaluated as follows:

    * Evaluate 5, and substitute it into the slotted expression (+ 2 $). This results in 7.

    * Pass 7 to the slotted expression (- 4 $), and evaluate. This results in -3.

    * Pass -3 to the slotted expression (* $ $) and evaluate. This results in 9.

If a slotted expression does not contain any $ slots, then the previous value will be ignored.

Similar to Clojure's \"thrush\"."
  (if (null slotted-exprs)
      expr
      (let ((g (gensym)))
        `(let ((,g ,expr))
           (declare (dynamic-extent ,g)
                    (ignorable ,g))
           (symbol-macrolet (($ ,g))
             (flow ,(car slotted-exprs) ,@(cdr slotted-exprs)))))))
