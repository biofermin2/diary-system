(in-package :cl-user)
(defpackage diary-system-test
  (:use :cl
        :diary-system
        :prove))
(in-package :diary-system-test)

;; NOTE: To run this test file, execute `(asdf:test-system :diary-system)' in your Lisp.

(plan nil)

;; blah blah blah.

(finalize)
