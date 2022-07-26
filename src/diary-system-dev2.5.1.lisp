;;#!/usr/bin/sbcl  --noinform
                                        ; -*- mode: Lisp; coding:utf-8 -*-
;; 開発目標 [2020-08-15 17:42:24]
;; restartを使って入力を完了させるようにしたい。

;; 稼働していたものを変更する事にする。[2020-07-15 01:29:41]
(load "/home/hiro/howm/junk/utils.lisp") ; => T
(qload :cffi :trivial-shell :local-time) ; => (:CFFI :TRIVIAL-SHELL :LOCAL-TIME)

;; Copyrightの表示
(copyright "diary-system" "dev2.5.1")	; =>
;; (:PROGRAM-NAME "diary-system" :VERSION "dev2.5.1" :COPYRIGHT "2020" :AUTHOR
;;  "Higashi, Hiromitsu" :LICENSE "MIT")

;; シェルをzshに変更 (デフォルトは "/bin/sh")
(setf trivial-shell:*bourne-compatible-shell* "/usr/bin/zsh") ; => "/usr/bin/zsh"
;; 日付の出力（太陽暦、太陰暦）
(defparameter *qdate* nil)		; => *QDATE*
(defparameter sun-date nil)		; => SUN-DATE
(defparameter luna-date nil)		; => LUNA-DATE
(setf *qdate*
	(split " "
	       (trivial-shell:shell-command "cut -f 2 -d: =(python ~/core/bin/qreki.py)"))) ; => ("2020年8月15日" "2020年6月26日")
(setf sun-date (car *qdate*))		; => "2020年8月15日"
(setf luna-date (trim (cadr *qdate*)))	; => "2020年6月26日"

;;(defparameter cls-con nil)		; => CLS-CON
;;(defparameter cls-con2 nil)		; => CLS-CON2
(defparameter cls-con3 nil)		; => CLS-CON2

;; (setf cls-con (let ((s nil))
;; 		(lambda () (push (read nil) s)))) ; => #<CLOSURE (LAMBDA ()) {1004B2A67B}>

(setf cls-con3 (let ((s nil))
		 (lambda (x) (push x s)))) ; => #<CLOSURE (LAMBDA (X)) {100482A47B}>

;; run5
(defun edit-contents (c)
  (apply #'concatenate 'string
	 (mapcar #'string (reverse (cdr c))))) ; => EDIT-CONTENTS

;; (define-condition not-a-percentage (error)
;;   ((dividend :initarg :dividend
;; 	     :reader dividend)
;;    (divisor :initarg :divisor
;; 	    :reader divisor))
;;   (:report (lambda (condition stream)
;; 	     (format stream
;; 		     "The quotient ~A/~A is not between 0 and 1."
;; 		     (dividend condition) (divisor condition))))) ; => NOT-A-PERCENTAGE

;;(mapcar #'cons '(:a :b :c) '(1 2 3))	; => ((:A . 1) (:B . 2) (:C . 3))
;; (mapcar #'list '(:a :b :c) '(1 2 3))	; => ((:A 1) (:B 2) (:C 3))
;; (funcall #'append '(:a :b :c) '(1 2 3))	; => (:A :B :C 1 2 3)
;;(mapcan #'list '(:a :b :c) '(1 2 3))	; => (:A 1 :B 2 :C 3)

;; (defun flatten (x)
;;   (labels ((rec (x acc)
;; 		(cond ((null x) acc)
;; 		      ((atom x) (cons x acc))
;; 		      (t (rec (car x) (rec (cdr x) acc))))))
;;     (rec x nil)))				      ; => FLATTEN
;; (flatten '(a (b c) ((d e) f)))			      ; => (A B C D E F)
;; (flatten (mapcar #'list '(a b c) '(1 2 3))) ; => (A 1 B 2 C 3)
;; (mapcar (compose #'flatten #'list) '(a b c) '(1 2 3)) ; => ((A 1) (B 2) (C 3))

;; (flatten
;;  (mapcar #'list
;; 		 '(:sun-date :luna-date :title :contents)
;; 		 '("2000-09-05" "2000-07-18" "test" "test-contents li1 li1 li li2 li2 2li"))) ; => (:SUN-DATE "2000-09-05" :LUNA-DATE "2000-07-18" :TITLE "test" :CONTENTS "test-contents li1 li1 li li2 li2 2li")
;; (mapcan #'list
;; 	'(:sun-date :luna-date :title :contents)
;; 	'("2000-09-05" "2000-07-18" "test" "test-contents li1 li1 li li2 li2 2li"))
;; 					; => (:SUN-DATE "2000-09-05" :LUNA-DATE "2000-07-18" :TITLE "test" :CONTENTS "test-contents li1 li1 li li2 li2 2li")

;; (defun readlist (&rest args)
;;   (values (read-from-string
;; 	   (concatenate 'string "("
;; 			(apply #'read-line args)
;; 			")"))))		; => READLIST
;; (defun prompt (&rest args)
;;   (apply #'format *query-io* args)
;;   (read *query-io*))			; => PROMPT

(defun run ()
  (loop
   (setf st1 (read))
   (setf c1 (funcall cls-con3 st1))
   (when (null st1)
     (return)))
  (edit-contents c1))		; => RUN

;; (defun run ()
;;   (restart-case
;;    (let ((ratio (/ a b)))
;;      (unless (typep ratio '(real 0 1))
;;        (error 'not-a-percentage :dividend a :divisor b))
;;      (format nil "~,2F%" (* 100 ratio)))
;;    (finish-input ()
;; 		     :report "EOF"
;; 		     :interactive (lambda ()
;; 				    (flet ((get-value (name)
;; 						      (format t "~&Enter new value for ~A: " name)
;; 						      (read)))
;; 				      (list (get-value 'a) (get-value 'b))))
;; 		     (run)))) ; => PERCENTAGE

;; (defun percentage (a b)
;;   (restart-case
;;    (let ((ratio (/ a b)))
;;      (unless (typep ratio '(real 0 1))
;;        (error 'not-a-percentage :dividend a :divisor b))
;;      (format nil "~,2F%" (* 100 ratio)))
;;    (use-other-values (new-a new-b)
;; 		     :report "Use two other values instead."
;; 		     :interactive (lambda ()
;; 				    (flet ((get-value (name)
;; 						      (format t "~&Enter new value for ~A: "
;; 							      name)
;; 						      (read)))
;; 				      (list (get-value 'a) (get-value 'b))))
;; 		     (percentage new-a new-b)))) ; => PERCENTAGE


(defun prompt-read (prompt)
  "プロンプト入力情報の読み込み"
  (format *query-io* "~a: " prompt)
  (force-output *query-io*)
  (read-line *query-io*))			; => PROMPT-READ

(defun prompt-read5 (prompt)
  "プロンプト入力情報の読み込みcontents用"
  (format *query-io* "~a: " prompt)
  (force-output *query-io*)
  (run))				; => PROMPT-REA5

(defun make-record (&key sun luna title contents)
  "plist形式でデータを格納する"
  (list :sun sun :luna luna :title title :contents contents)) ; => MAKE-RECORD

(defun write-diary ()
  "プロンプトから問い合わせながらデータ入力できる機能"
  (make-record
   :sun sun-date
   :luna luna-date
   :title (prompt-read "title")
   :contents (prompt-read5 "contents"))) ; => WRITE-DIARY

(defvar *db* nil "一時データ格納領域の定義") ; => *DB*

(defun add-record (d)
  "データをデータベースへ追加する"
  (push d *db*))			; => ADD-RECORD

(defun write-diaries ()
  "複数の日記データをプロンプトから書く機能"
  (loop (add-record (write-diary))
     (if (not (y-or-n-p "Another? [y/n]: "))
	 (return)))) ; => WRITE-DIARIES

(defun save-db (filename)
  "データベースの名前付け保存"
  (with-open-file (out filename
                       :direction :output
                       :if-exists :append
                       :if-does-not-exist :create)
    (with-standard-io-syntax
      (print *db* out))))		; => SAVE-DB

(defun main ()
  (unwind-protect
      (write-diaries)
    (save-db "~/howm/junk/diary.db")))	; => MAIN

(main)					; =>
