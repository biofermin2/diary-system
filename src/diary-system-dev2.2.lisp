;;#!/usr/bin/sbcl  --noinform
                                        ; -*- mode: Lisp; coding:utf-8 -*-
;; 稼働していたものを変更する事にする。[2020-07-15 01:29:41]
#.(load "/home/hiro/howm/junk/utils.lisp") ; => T
(qload :trivial-shell :local-time)	   ; => (:TRIVIAL-SHELL :LOCAL-TIME)

;; Copyrightの表示
(copyright "diary-system" "dev2.2")	; =>
;; (:PROGRAM-NAME "diary-system" :VERSION "dev2.2" :COPYRIGHT "2020" :AUTHOR
;;  "Higashi, Hiromitsu" :LICENSE "MIT")

;; シェルをzshに変更 (デフォルトは "/bin/sh")
(setf trivial-shell:*bourne-compatible-shell* "/usr/bin/zsh") ; => "/usr/bin/zsh"

;; 日付の出力（太陽暦、太陰暦）
(defparameter *qdate* nil)		; => *QDATE*
(setf *qdate*
	(split " "
	       (trivial-shell:shell-command "cut -f 2 -d: =(python ~/core/bin/qreki.py)"))) ; => ("2020年7月29日" "2020年6月9日")
(setf sun-date (car *qdate*))		 ; => "2020年7月29日"
(setf luna-date (trim (cadr *qdate*))) ; => "2020年6月9日"

(defparameter *my-diary* nil)							;=> *MY-DIARY*
;;;; diary.lisp version 1
;; (defun make-record (sun-date luna-date title contents)
;; 	"plist形式でデータを格納する"
;; 	(list :sun-date sun-date :luna-date luna-date :title title :contents contents)) ;=> MAKE-RECORD

;; (defun make-record (sun-date luna-date title contents)
;; 	"instanceでデータを格納する"
;; 	(*my-diary*))													;=> MAKE-RECORD

;; (defvar *interrupt-condition*
;;   ;; It seems abcl does not raise any conditions
;;   #+allegro 'excl:interrupt-signal
;;   #+ccl 'ccl:interrupt-signal-condition
;;   #+clisp 'system::simple-interrupt-condition
;;   #+ecl 'ext:interactive-interrupt
;;   #+sbcl 'sb-sys:interactive-interrupt
;;   #-(or allegro ccl clisp ecl sbcl) 'no-conditon-known) ; => *INTERRUPT-CONDITION*

;; (defmacro with-handle-interrupt (&body body)
;;   `(handler-case
;;        #-ccl(progn
;;               ,@body)
;;        #+ccl (let ((ccl:*break-hook* (lambda (condition hook)
;;                                        (declare (ignore hook))
;;                                        (error condition))))
;;                ,@body)
;;        (#.*interrupt-condition* (c)
;;          (handle-interrupt c))))	; => WITH-HANDLE-INTERRUPT

;; (defun write-content (str)
;;   "^cで処理の終了"
;;   (handler-case
;;       (with-output-to-string (str)
;; 	(print (unwind-protect (while t
;; 				 (read))) str))
;;     (sb-kernel::interactive-interrupt (int)
;;       (declare (ignorable int))
;;       (format t "caught sigint."))))	; => WRITE-CONTENT

;; (defun write-content (str)
;;   "^cで処理の終了"
;;   (with-handler-interrupt
;;       (with-output-to-string (str)
;; 	(print (while t
;; 		 (read)) str))))	; => WRITE-CONTENT

(let ((s nil))
  (defun in_closure ()
    "クロージャー内に文字列格納"
    (lambda ()
      (push (read) s))))		; => IN_CLOSURE
;;>(in_closure)
;;>#<CLOSURE (LAMBDA () :IN IN_CLOSURE) {1005AEE11B}>
;;>(funcall (in_closure))
;;>(TEST1 BBBB AAAA)

(setf a (let ((s nil))
	  (lambda () (push (read) s))))	; => #<CLOSURE (LAMBDA ()) {1003C2B1FB}>
;;>(funcall a)
;;> (TEST2 TEST1)
(setf a2 (let ((s nil))
	   (lambda () (cons (read) s)))) ; => #<FUNCTION (LAMBDA ()) {1001F1048B}>
(setf a3 (let ((s nil))
	   (lambda (x) (cons x s)) (read))) ; => TEST1

(setf a4 (let ((s nil))
	   (lambda (x) (cons x s))))	; => #<FUNCTION (LAMBDA (X)) {1001F106BB}>

((let ((s nil))
	(lambda (x) (cons x s)) (read)))	; =>

(setf b2 (let ((a nil))
	   (lambda () (push x a))))	; => #<CLOSURE (LAMBDA ()) {1003EA6FAB}>
;;>(push (read) b2)
;;>(TEST1 . #<CLOSURE (LAMBDA ()) {1003EA6FAB}>)

(setf b3 (let ((a nil))
	   (lambda () (cons x a)) (read))) ; => TEST1

(setf b (let ((a nil))
	  (lambda (x) (push x a))))	; => #<CLOSURE (LAMBDA (X)) {1003A3D04B}
;;>(push (read) b)
;;>(TEST1 . #<CLOSURE (LAMBDA (X)) {1003A3D04B}>)

(setf d (let ((a nil))
	  (lambda (x) (x))))		; => #<FUNCTION (LAMBDA (X)) {1001AC1B4B}>
;;>(push (read) d)
;;>(TEST1 . #<FUNCTION (LAMBDA (X)) {1001AC1B4B}>)

;; usage:(funcall (in_closure))
;; 最終的にクロージャーの中身を保持しておきたい時は
;; (setf x (funcall (in_closure)))
;; とやってxに格納する。
(defun run ()
  (handler-case
      (while t
	(setf b (funcall a)))
    (sb-kernel::interactive-interrupt (int)
				      (declare (ignorable int))
				      (format t "caught sigint.")))) ; => RUN

(defun prompt-read (prompt)
  "プロンプト入力情報の読み込み"
  (format *query-io* "~a: " prompt)
  (force-output *query-io*)
  (read *query-io*))			; => PROMPT-READ

(defun prompt-read2 (prompt)
  "プロンプト入力情報の読み込みcontents用"
  (format *query-io* "~a: " prompt)
  (force-output *query-io*)
  (princ b *query-io*))	; => PROMPT-READ2
;; prompt-readをクロージャーで書き換えるか？[2020-07-30 02:52:42]


;; (defun write-diary ()
;;   "プロンプトから問い合わせながらデータ入力できる機能"
;;   (make-record
;;    :sun sun-date
;;    :luna luna-date
;;    :title (prompt-read "title")
;;    :contents (prompt-read "contents")))	; => WRITE-DIARY
(defun write-diary ()
  "プロンプトから問い合わせながらデータ入力できる機能"
  (make-record
   :sun sun-date
   :luna luna-date
   :title (mkstr (prompt-read "title"))
   :contents (mkstr (prompt-read2 "contents")))) ; => WRITE-DIARY

(defun mkstr (&rest args)
  (with-output-to-string (s)
			 (dolist (a args) (princ a s)))) ; => MKSTR
;; sun-date						 ; => "2020年7月29日"
;; (mkstr sun-date)					 ; => "2020年7月29日"
(defun make-record (&key sun luna title contents)
  "plist形式でデータを格納する"
  `(:sun ,sun :luna ,luna :title ,title :contents ,contents)) ; => MAKE-RECORD
;;(make-record :sun "2008" :luna "2233" :title "test" :contents "tes1") ; => (:SUN "2008" :LUNA "2233" :TITLE "test" :CONTENTS "tes1")

(defvar *db* nil "一時データ格納領域の定義") ; => *DB*

(defun add-record (d)
  "データをデータベースへ追加する"
  (push d *db*))			; => ADD-RECORD

(defun dump-db ()
  "指定したデータベース情報を読みやすい形式で整形出力"
  (format t "~{~{~a:~10t~a~%~}~%~}" *db*)) ; => DUMP-DB

(defun write-diaries ()
  "複数の日記データをプロンプトから書く機能"
  (loop (add-record (write-diary))
     (if (not (y-or-n-p "Another? [y/n]: ")) (return)))) ; => WRITE-DIARIES

(defun save-db (filename)
  "データベースの名前付け保存"
  (with-open-file (out filename
                       :direction :output
                       :if-exists :append
                       :if-does-not-exist :create)
    (with-standard-io-syntax
      (print *db* out))))		; => SAVE-DB

(defun load-db (filename)
  "データベースの読み込み"
  (with-open-file (in filename)
    (with-standard-io-syntax
      (setf *db* (read in)))))		; => LOAD-DB

(defun select (keyword)
  "keywordに沿ってデータを抽出選択する"
  (remove-if-not keyword *db*))		; => SELECT

(defun make-comparison-expr (field value)
  `(equal (getf d ,field) ,value))

(defun make-comparisons-list (fields)
  (loop while fields
     collecting (make-comparison-expr (pop fields) (pop fields))))

(defmacro where (&rest clauses)
  `#'(lambda (d) (and ,@(make-comparisons-list clauses))))

;;(select (where :title "test"))					; => NIL

(defun update (keyword &key date old-date title contents)
  "データーベースの更新"
  (setf *db*
        (mapcar
         #'(lambda (row)
             (when (funcall keyword row)
               (if date (setf (getf row :title) title))
               (if old-date (setf (getf row :old-date) old-date))
               (if title (setf (getf row :title) title))
               (if contents (setf (getf row :contents) contents)))
             row) *db*)))

(defun delete-rows (keyword)
  "データーベースからレコードを削除する"
  (setf *db* (remove-if keyword *db*)))

(defclass table ()
  ((rows :accessor rows :initarg :rows :initform (make-rows))
   (schema :accessor schema :initarg :schema)))

(defparameter *default-table-size* 100)

(defun make-rows (&optional (size *default-table-size*))
  (make-array size :adjustable t :fill-pointer 0))

(defun day-of-week (day month year)
  "Returns the day of the week as an integer.Monday is 0.Unfortunately,
by definition, this function won't work for dates before January 1, 1900. "
  (nth-value
   6
   (decode-universal-time
    (encode-universal-time 0 0 0 day month year 0)
    0)))															; => DAY-OF-WEEK

(defun main ()
  (unwind-protect
       (write-diaries)
    (save-db "~/howm/junk/diary.db")))	; => MAIN

(main)					; =>

;; (defun openi (file &key (element-type 'cl:character) (external-forma
;; 						      t :utf-8))
;;   (open file :direction :input
;;         :element-type element-type
;;         :external-format external-format))

;; (defun openo (file &key (element-type 'cl:character) (external-format :utf-8))
;;   (open file
;;         :direction :output
;;         :element-type element-type
;;         :external-format external-format
;;         :if-exists :supersede
;;         :if-does-not-exist :create))

;; (defun opena (file &key (element-type 'cl:character) (external-format :utf-8))
;;   (open file
;;         :direction :output
;;         :element-type element-type
;;         :external-format external-format
;;         :if-exists :append
;;         :if-does-not-exist :create))

;; 位の所ですが、Inputのi、Outputのo、Appendのa がopenの後ろに一文字付いています。

;; 使い方としては、

;; (with-open-stream (out (opena "/tmp/foo"))
;;   (write-line "おはよう日本" out))

;; (with-open-stream (in (openi "/tmp/foo"))
;;   (read-line in))
;; ⊳ "おはよう日本"
