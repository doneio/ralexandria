# ralexandria

Split Alexandria into smaller, independently testable systems organized by theme.

## Todo
- Add all the functionality from Alexandria.
- Make an Alexandria package for backwards compatibility, that depends on the independent systems.

## Validation

```lisp
(asdf:test-system :ralexandria)

All tests pass successfully on SBCL (Windows):

- ralexandria.clos
- ralexandria.clos.print-method-for
- ralexandria.clos.tracked-class
- ralexandria.macros
- ralexandria.macros.with-accessors
- ralexandria.prog
- ralexandria.prog.proj
- ralexandria.prog.renaming
- ralexandria.prog.continuations
- ralexandria.reader.multiline-string-impl
- ralexandria.sequences
- ralexandria.strings
- ralexandria.strings.regex
