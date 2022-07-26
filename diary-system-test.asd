#|
  This file is a part of diary-system project.
  Copyright (c) 2019 h.hiro (supercaveman@mail.com)
|#

(in-package :cl-user)
(defpackage diary-system-test-asd
  (:use :cl :asdf))
(in-package :diary-system-test-asd)

(defsystem diary-system-test
  :author "h.hiro"
  :license "MIT"
  :depends-on (:diary-system
               :prove)
  :components ((:module "t"
                :components
                ((:test-file "diary-system"))))
  :description "Test system for diary-system"

  :defsystem-depends-on (:prove-asdf)
  :perform (test-op :after (op c)
                    (funcall (intern #.(string :run-test-system) :prove-asdf) c)
                    (asdf:clear-system c)))
