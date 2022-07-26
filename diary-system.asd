#|
  This file is a part of diary-system project.
  Copyright (c) 2019 h.hiro (supercaveman@mail.com)
|#

#|
  Author: h.hiro (supercaveman@mail.com)
|#

(in-package :cl-user)
(defpackage diary-system-asd
  (:use :cl :asdf))
(in-package :diary-system-asd)

(defsystem diary-system
  :version "0.1"
  :author "h.hiro"
  :license "MIT"
  :depends-on ()
  :components ((:module "src"
                :components
                ((:file "diary-system"))))
  :description "S式簡易日記システム S-expression Simple Diary System"
  :long-description
  #.(with-open-file (stream (merge-pathnames
                             #p"README.markdown"
                             (or *load-pathname* *compile-file-pathname*))
                            :if-does-not-exist nil
                            :direction :input)
      (when stream
        (let ((seq (make-array (file-length stream)
                               :element-type 'character
                               :fill-pointer t)))
          (setf (fill-pointer seq) (read-sequence seq stream))
          seq)))
  :in-order-to ((test-op (test-op diary-system-test))))
