;;#!/usr/bin/sbcl  --noinform
;; -*- mode: Lisp; coding:utf-8 -*-

;; 稼働していたものを変更する事にする。[2020-07-15 01:29:41]
(load "/home/hiro/howm/junk/utils.lisp") ; => T
(qload :trivial-shell :local-time)	 ; => (:TRIVIAL-SHELL :LOCAL-TIME)
;; Copyrightの表示
(copyright "diary-system" "dev2.7.1")	; =>
;; (:PROGRAM-NAME "diary-system" :VERSION "dev2.7" :COPYRIGHT "2020" :AUTHOR
;;  "Higashi, Hiromitsu" :LICENSE "MIT")

;; シェルをzshに変更 (デフォルトは "/bin/sh")
(setf trivial-shell:*bourne-compatible-shell* "/usr/bin/zsh") ; => "/usr/bin/zsh"

(defun make-cls ()
  (let ((s nil))
    (lambda (x) (push x s))))	; => MAKE-CLS

(defconstant +p-key+ '(:sun :luna :title :contents) "キーワードリスト") ; => +P-KEY+
(defparameter p-str nil "コンテンツのデータ格納エリア")			; => P-STR
(defparameter p-con nil "contents専用のデータ格納エリア")	; => P-CON

(setf p-str (make-cls))	  ; => #<CLOSURE (LAMBDA (X) :IN MAKE-CLS) {1005C597BB}>
(setf p-con (make-cls))	  ; => #<CLOSURE (LAMBDA (X) :IN MAKE-CLS) {1005C6A26B}>

(funcall p-str
	 (split " " (string-right-trim '(#\Newline)
				       (trivial-shell:shell-command
					"cut -f 2 -d: =(python ~/core/bin/qreki.py)")))) ; => (("2020年9月9日" "2020年7月22日"))

(defun flatten (x)
  (labels ((rec (x acc)
		(cond ((null x) acc)
		      ((atom x) (cons x acc))
		      (t (rec (car x) (rec (cdr x) acc))))))
    (rec x nil)))			; => FLATTEN

(defun run ()
  (loop
   (let* ((st1 (read-line))
	  (c1 (funcall p-con st1)))
     (when (null st1)
       (return))))
  (setf c2 (reverse c1)))					; => RUN

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
				  (flatten (reverse (funcall p-str (apply #'concatenate 'string c2))))) out)))) ; => SAVE-DB

(defun main ()
  (unwind-protect
      (progn
	(funcall p-str (prompt-read "title"))
	(prompt-read "contents"))
    (save-db "~/howm/junk/diary.db")))	; => MAIN

(main)					; =>
