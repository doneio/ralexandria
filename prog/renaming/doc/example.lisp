;;; See test/example1/lisp

#|
Inspired by:
"In Joseph Goguen's OBJ3 language, renaming is a way of changing the names of sorts and/or operators in a module while preserving their underlying algebraic structure.

For example, suppose you have a module containing:

sort Nat .
op 0 : -> Nat .
op s : Nat -> Nat .

A renaming can map:

Nat -> Integer
0   -> zero
s   -> successor

Conceptually, the resulting module has:

sort Integer .
op zero : -> Integer .
op successor : Integer -> Integer .

Renaming is especially important when combining or importing modules. It lets you reuse an existing specification without causing name clashes or forcing you to modify the original module.

For instance, if two imported modules both have an operator called empty, you can rename one of them:

empty -> emptySet

so that both modules can be imported and coexist.

OBJ3's renaming mechanism is a signature morphism: it maps the symbols (sorts and operators) of one signature to symbols in another signature. Equations and other semantic structure are transported along that mapping.

Renaming = systematically replacing the names of the symbols of a module, while retaining their types and equations under the corresponding mapping.

This is different from simply doing a textual find-and-replace: the renaming has to respect the sorts, operator profiles, and algebraic semantics of the specification."
|#

#|
(ralexandria.prog.renaming:renaming (:macro)
     (ralexandria.with-accessors:with-accessors))
;;; macroexpands to
(defmacro with-accessors (...) ; calls the original functionality:
  (ralexandria.with-accessors:with-accessors ...))
|#
