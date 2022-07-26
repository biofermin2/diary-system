;;#!/usr/bin/sbcl  --noinform
;; -*- mode: Lisp; coding:utf-8 -*-

;; 稼働していたものを変更する事にする。[2020-07-15 01:29:41]
(load "/home/hiro/howm/junk/utils.lisp") ; => T
(qload :cffi :trivial-shell :local-time) ; => (:CFFI :TRIVIAL-SHELL :LOCAL-TIME)
;; Copyrightの表示
(copyright "diary-system" "dev2.6")	; =>
;; (:PROGRAM-NAME "diary-system" :VERSION "dev2.6" :COPYRIGHT "2020" :AUTHOR
;;  "Higashi, Hiromitsu" :LICENSE "MIT")

;; シェルをzshに変更 (デフォルトは "/bin/sh")
(setf trivial-shell:*bourne-compatible-shell* "/usr/bin/zsh") ; => "/usr/bin/zsh"
;; 日付の出力（太陽暦、太陰暦）
;;(defparameter *qdate* nil) ; => *QDATE*
;; (defparameter sun-date nil)		; => SUN-DATE
;; (defparameter luna-date nil)		; => LUNA-DATE

(defun make-cls ()
      (let ((s nil))
	(lambda (x) (push x s))))	; => MAKE-CLS
;;(defparameter p-key nil)		; => P-KEY
(defconstant +p-key+ '(:sun :luna :title :contents)) ; => +P-KEY+
(defparameter p-str nil)		; => P-STR
;;(setf p-key (make-cls))			; => #<CLOSURE (LAMBDA (X) :IN MAKE-CLS) {1002368B3B}>
(setf p-str (make-cls))			; => #<CLOSURE (LAMBDA (X) :IN MAKE-CLS) {1001A88B9B}>
;;(funcall p-key '(:sun :luna :title :contents)) ; => ((:SUN :LUNA :TITLE :CONTENTS))
(funcall p-str
	 (split " " (string-right-trim '(#\Newline)
				       (trivial-shell:shell-command
					"cut -f 2 -d: =(python ~/core/bin/qreki.py)")))) ; => (("2020年9月9日" "2020年7月22日"))
					; => (("2020年7月22日"))
					; => ("2020年9月9日")
;; => ("2020年9月9日" NIL (LI3 LI3 LI3) (LI2 LI2 LI2) (LI1 LI1 LI1) "dev2.6" ("2020年9月9日" "2020年7月22日"))

;; (setf cls-con3 (let ((s nil))
;;  		 (lambda (x) (push x s)))) ; => #<CLOSURE (LAMBDA (X)) {1003CB49DB}>

;; (car (funcall cls-con3 '(a b c)))	   ; => (A B C)
;; (cdr (funcall cls-con3 '(a b c)))	; => ((A B C) (A B C) (A B C) (A B C))
;; (setf cls-con4 (let ((s nil))
;; 		 (lambda (x) (push x s)))) ; => #<CLOSURE (LAMBDA (X)) {1003CF3D5B}>
;; (funcall cls-con3 '(a b c))		   ; => ((A B C))
;; (funcall cls-con4 '(e d f))		   ; => ((E D F))
;; (car (last (funcall cls-con3 nil)))	   ; => (A B C)
;; (car (last (funcall cls-con4 nil)))	   ; => (E D F)
;; (car (mapcar #'append (cdr (funcall cls-con3 nil)) (cdr (funcall cls-con4 nil)))) ; => (A B C E D F)
;; ;; ok
;; (mapcan #'list (car (last (funcall cls-con3 nil))) (car (last (funcall cls-con4 nil)))) ; => (A E B D C F)
;; (append '((a b c)) '((e d f)))						  ; => ((A B C) (E D F))
;; (mapcan #'list (car '((a b c))) (car '((e d f))))			  ; => (A E B D C F)
;; run5
(defun edit-contents (c)
  (apply #'concatenate 'string
	 (mapcar #'string (reverse (cdr c))))) ; => EDIT-CONTENTS

(concatenate 'string "aaa bbb ccc" "ddd eee fff" "gg") ; => "aaa bbb cccddd eee fffgg"
(concatenate 'string "今日はいい天気です" "明日は雨です。" "でも明後日は晴れます。") ; => "今日はいい天気です明日は雨です。でも明後日は晴れます。"
;; readは一文字区切りまで。スペースが空いていたら手前まで読み込む。読んだまま評価。
;; read-lineは１行まるまる読み込む。改行するまで。文字列として評価する。
;; readlistは読み込んだ文字列は全て括弧で囲って評価する。

;;(mapcar #'cons '(:a :b :c) '(1 2 3))	; => ((:A . 1) (:B . 2) (:C . 3))
;; (mapcar #'list '(:a :b :c) '(1 2 3))	; => ((:A 1) (:B 2) (:C 3))
;; (funcall #'append '(:a :b :c) '(1 2 3))	; => (:A :B :C 1 2 3)
;;(mapcan #'list '(:a :b :c) '(1 2 3))	; => (:A 1 :B 2 :C 3)

(defun flatten (x)
  (labels ((rec (x acc)
		(cond ((null x) acc)
		      ((atom x) (cons x acc))
		      (t (rec (car x) (rec (cdr x) acc))))))
    (rec x nil)))			; => FLATTEN
;; (flatten '(a (b c) ((d e) f)))			      ; => (A B C D E F)
;; (flatten (mapcar #'list '(a b c) '(1 2 3))) ; => (A 1 B 2 C 3)
;; (mapcan #'list
;; 	'(:sun-date :luna-date :title :contents)
;; 	'("2000-09-05" "2000-07-18" "test" "test-contents li1 li1 li li2 li2 2li"))
;; 					; => (:SUN-DATE "2000-09-05" :LUNA-DATE "2000-07-18" :TITLE "test" :CONTENTS "test-contents li1 li1 li li2 li2 2li")

(defun readlist (&rest args)
  (values (read-from-string
	   (concatenate 'string "("
			(apply #'read-line args)
			")"))))		; => READLIST

;; (defun prompt (&rest args)
;;   (apply #'format *query-io* args)
;;   (read *query-io*))			; => PROMPT
(setf st1 nil)				; => NIL
(setf c1 nil)				; => NIL

(defun run ()
  (loop
   (setf st1 (read-line))		;
   (setf c1 (funcall p-str st1))	; =>
   (when (null st1)
     (return)))
  (flatten c1))			; => RUN
;;(flatten c1)				; => (LI3 LI3 LI3 LI2 LI2 LI2 LI1 LI1 LI1 "dev2.6" "2020年9月9日" "2020年7月22日")
;;(edit-contents (flatten c1))		; => "2020年7月22日2020年9月9日dev2.6LI1LI1LI1LI2LI2LI2LI3LI3"
;;c1					; => ((LI3 LI3 LI3) (LI2 LI2 LI2) (LI1 LI1 LI1) "dev2.6" ("2020年9月9日" "2020年7月22日"))
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
		    (flatten (reverse c1))) out)))) ; => SAVE-DB

(defun main ()
  (unwind-protect
      (progn
	(funcall p-str (prompt-read "title"))
	(funcall p-str (prompt-read "contents")))
    (save-db "~/howm/junk/diary.db")))	; => MAIN

(main)					; =>
