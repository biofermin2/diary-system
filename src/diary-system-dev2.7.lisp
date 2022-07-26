;;#!/usr/bin/sbcl  --noinform
;; -*- mode: Lisp; coding:utf-8 -*-

;; 稼働していたものを変更する事にする。[2020-07-15 01:29:41]
(load "/home/hiro/howm/junk/utils.lisp") ; => T
(qload :cffi :trivial-shell :local-time) ; => (:CFFI :TRIVIAL-SHELL :LOCAL-TIME)
;; Copyrightの表示
(copyright "diary-system" "dev2.7")	; =>
;; (:PROGRAM-NAME "diary-system" :VERSION "dev2.7" :COPYRIGHT "2020" :AUTHOR
;;  "Higashi, Hiromitsu" :LICENSE "MIT")

;; シェルをzshに変更 (デフォルトは "/bin/sh")
(setf trivial-shell:*bourne-compatible-shell* "/usr/bin/zsh") ; => "/usr/bin/zsh"

(defun make-cls ()
  (let ((s nil))
    (lambda (x) (push x s))))	; => MAKE-CLS

(defconstant +p-key+ '(:sun :luna :title :contents)) ; => +P-KEY+
(defparameter p-str nil)		; => P-STR
(defparameter p-con nil)		; => P-CON

(setf p-str (make-cls))			; => #<CLOSURE (LAMBDA (X) :IN MAKE-CLS) {1001A88B9B}>
(setf p-con (make-cls))			; => #<CLOSURE (LAMBDA (X) :IN MAKE-CLS) {10020835CB}>

(funcall p-str
	 (split " " (string-right-trim '(#\Newline)
				       (trivial-shell:shell-command
					"cut -f 2 -d: =(python ~/core/bin/qreki.py)")))) ; => (("2020年9月9日" "2020年7月22日"))

(defun edit-contents (c)
  (apply #'concatenate 'string
	 (mapcar #'string (reverse (cdr c))))) ; => EDIT-CONTENTS

;; (concatenate 'string "aaa bbb ccc" "ddd eee fff" "gg") ; => "aaa bbb cccddd eee fffgg"
;; (concatenate 'string "今日はいい天気です" "明日は雨です。" "でも明後日は晴れます。") ; => "今日はいい天気です明日は雨です。でも明後日は晴れます。"
;; readは一文字区切りまで。スペースが空いていたら手前まで読み込む。読んだまま評価。
;; read-lineは１行まるまる読み込む。改行するまで。文字列として評価する。
;; readlistは読み込んだ文字列は全て括弧で囲って評価する。

(defun flatten (x)
  (labels ((rec (x acc)
		(cond ((null x) acc)
		      ((atom x) (cons x acc))
		      (t (rec (car x) (rec (cdr x) acc))))))
    (rec x nil)))			; => FLATTEN

(defun readlist (&rest args)
  (values (read-from-string
	   (concatenate 'string "("
			(apply #'read-line args)
			")"))))		; => READLIST

(setf st1 nil)				; => NIL
(setf c1 nil)				; => NIL

(defun run ()
  (loop
   (setf st1 (read-line))		;
   (setf c1 (funcall p-con st1))	; =>
   (when (null st1)
     (return)))
  c1) ; => RUN

;;(flatten c1)				; => (LI3 LI3 LI3 LI2 LI2 LI2 LI1 LI1 LI1 "dev2.6" "2020年9月9日" "2020年7月22日")
;;(edit-contents (flatten c1))		; => "2020年7月22日2020年9月9日dev2.6LI1LI1LI1LI2LI2LI2LI3LI3"
;;c1					; => ((LI3 LI3 LI3) (LI2 LI2 LI2) (LI1 LI1 LI1) "dev2.6" ("2020年9月9日" "2020年7月22日"))
;;contents ("li3 li3 li3" "li2 li2 li2" "li1 li1 li1")<-現在予想
;; ->"li1 li1 li1
;; li2 li2 li2
;; li3 li3 li3" という評価になってほしい。
;;(format t "~s~%" '("hoge a" "foo b" "bar c")) ; => ("hoge a" "foo b" "bar c")
;;(format t "~a~%" '("hoge a" "foo b" "bar c")) ; => (hoge a foo b bar c)
;;(format t "~{~s~}" '("hoge a" "foo b" "bar c")) ; => "hoge a""foo b""bar c"NIL
;; ok
;; (setf con1 '("hoge a" "foo b" "bar c"))	; => ("hoge a" "foo b" "bar c")
;; (apply #'concatenate 'string con1)	; => "hoge afoo bbar c"

(defun prompt-read (prompt)
  "プロンプト入力情報の読み込み"
  (format *query-io* "~a: " prompt)
  (force-output *query-io*)
  (if (equal prompt "title")
      (read-line *query-io*)
    (run)))				; => PROMPT-READ

(defun save-db (filename)
  "データベースの名前付け保存"
  (with-open-file (out filename
                       :direction :output
                       :if-exists :append
                       :if-does-not-exist :create)
		  (with-standard-io-syntax
		   (print (mapcan #'list
				  +p-key+
				  (flatten (reverse (funcall p-str (apply #'concatenate 'string (reverse c1)))))) out)))) ; => SAVE-DB

(defun main ()
  (unwind-protect
      (progn
	(funcall p-str (prompt-read "title"))
	(prompt-read "contents"))
    (save-db "~/howm/junk/diary.db")))	; => MAIN

(main)					; =>
