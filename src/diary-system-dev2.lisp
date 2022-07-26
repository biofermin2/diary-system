#!/usr/bin/sbcl  --noinform
                                        ; -*- mode: Lisp; coding:utf-8 -*-
;;;; S式簡易日記システム
;;; 開発目標

;; [2020-07-13 13:12:25]
;; make-record なんて関数ない。本を読むとplistを作成する関数になっている。
;; しかし、ここではplistではなくinstanceを使っている。
;; plistを作成してからinstanceに変換する方法はあるのか？
;; それともダイレクトにinstanceにsetfで入れてしまうか？

;; 新qreki.pyに対応済[2020-06-12 13:35:04]
;; 文字列の保存をクロージャーに格納出来ないか？
;; read-sequence,write-sequence,unwind-protectを使って
;; 日記入力時に何行にも亘って入力が出来るようにする。（現在はread-lineを使っているため、
;; enterで改行すると、入力終了となる。）
;; utils.lispは既存のライブラリを読み込まなければいいけない箇所は無くす。
;; 例えばquicklispに依存している箇所など。[2020-06-12 11:09:16]
#.(load "/home/hiro/howm/junk/utils.lisp") ; => T
(qload :trivial-shell :local-time)	   ; => (:TRIVIAL-SHELL :LOCAL-TIME)
;; (require 'asdf)				; => NIL
;; (require 'local-time)			; => NIL
;; (require ' trivial-shell)		; => NIL

;; Copyrightの表示
(copyright "diary-system" "dev2.0")	; =>
;; (:PROGRAM-NAME "diary-system" :VERSION "dev2.0" :COPYRIGHT "2020" :AUTHOR
;; 	       "Higashi, Hiromitsu" :LICENSE "MIT")


;; シェルをzshに変更 (デフォルトは "/bin/sh")
(setf trivial-shell:*bourne-compatible-shell* "/usr/bin/zsh") ; => "/usr/bin/zsh"
;; (let ((qdate (trivial-shell:shell-command "cut -f 2 -d: =(python -m ~/core/bin/qreki)")))
;;   	(format t "~A" qdate))		; => NIL
(multiple-value-bind (sun-date luna-date)
    (let* ((qdate (split " " (trivial-shell:shell-command "cut -f 2 -d: =(python ~/core/bin/qreki.py)")))
	   (sun (car qdate))
	   (luna (cadr qdate)))
      (setf sun-date sun
	    luna-date (trim luna))))	; => NIL
;; sun-date				; => "2020年7月15日"
;; luna-date				; => "2020年5月25日"

;; class定義の仕方
;; (defclass name (superclasses)
;;   (slots)
;;   options)

;;     :initarg - クラスのインスタンスが作成されたときにスロットに値を与えるときに使用される keyword
;;     :initform - もしスロットのための何の値も与えられない場合は、 initform が評価された結果に初期化されます。 initform がなければエラーが返されます。
;;     :reader - 関数に特定のスロットを読み込むように指定します。 :reader aaa の意味するところは、 aaa という関数を作成し、 aaa のインスタンスはスロットの値を返すようにしろ、ということです。
;;     :writer - 関数に特定のスロットに書き込むように指定します。 :writer bbb の意味するところは、 bbb という関数を作成し、 bbb の値のインスタンスは、インスタンスのスロットに値をセットしろ、ということです。
;;     :accessor - 関数にスロットの値を読み書きするように指定します。 :accessor foo の意味するところは、 foo という関数を作成し、さらに (setf foo) という関数を作成し、そして (foo instance) でスロットの値を読み込み、そして (setf (foo instance) value) でスロットの値をセットします。
;;         Node: :reader foo :writer foo は異なります。 reader と writer の名前は違うものにしなくてはなりません。代わりに :accessor を使用してください。
;;     :documentation - 特定のスロットに文書文字列を作成します。

;; 全てのオプションは完全に任意ですが、しかし少なくとも一つの :initarg か、あるいは :initform はオブジェクトが作成されたときにスロットの初期化が可能なように、与えられなければなりません。失敗するとランタイムエラーを返します。

;; クラスのオプションとして、唯一便利なのが :documentation です。これは全てのクラスに文書文字列を提供します。

;; (defclass diary ()
;;   ((sun-date :initarg :sun-date :initform "" :accessor sun-date)
;;    (luna-date :initarg :luna-date :initform "" :accessor luna-date)
;;    (title :initarg :title :initform "" :accessor title)
;;    (contents :initarg :contents :initform "" :accessor contents)) ; =>
;;   (:documentation "日記フォーマットクラスの定義")) ; =>

;; (defparameter *my-diary* nil
;;   "日記フォーマットのインスタンス用変数の定義") ; => *MY-DIARY*

;; ;; インスタンス用変数にフォーマットの初期値を代入
;; (setf *my-diary* (make-instance 'diary
;;                                 :sun-date sun-date
;;                                 :luna-date luna-date
;;                                 :title nil
;; 				:contents nil)) ; => #<DIARY {100498EDA3}>

;;*my-diary*				; => #<DIARY {1001F8BEF3}>
;;(print-object *my-diary* *standard-output*)  ; => #<DIARY {1001A29233}>NIL
;;(sun-date *my-diary*)			       ; => "2020年6月12日"
;;(luna-date *my-diary*)			; => "2020年閏4月21日"
;; (slot-value *my-diary* 'sun-date)	; => "2020年6月22日"
;; (slot-value *my-diary* 'luna-date)	; => "2020年5月2日"
;; (slot-value *my-diary* 'title)		; => ""

;;  (describe *my-diary*)			; => #<DIARY {1001F8BEF3}>
;;   [standard-object]

;; Slots with :INSTANCE allocation:
;;   SUN-DATE                       = "2020年7月13日"
;;   LUNA-DATE                      = "2020年5月23日"
;;   TITLE                          = "テスト"
;;   CONTENTS                       = "test"

(defun write-content (str)
  "^cで処理の終了"
  (handler-case
      (with-output-to-string (str)
	(while t
	  (print (read))))
    (sb-kernel::interactive-interrupt (int)
      (declare (ignorable int))
      (format t "caught sigint."))))	; => WRITE-CONTENT

(defvar *db* nil "日記データベース一次格納域の定義") ; => *DB*

(defun prompt-read (prompt)
  "プロンプト入力情報の読み込み"
  (format *query-io* "~a: " prompt)
  (force-output *query-io*)
  (read *query-io*))			; => PROMPT-READ

(defun prompt-read2 (prompt)
  "プロンプト入力情報の読み込みcontents用"
  (format *query-io* "~a: " prompt)
  (force-output *query-io*)
  (write-content *query-io*))		; => PROMPT-READ2

(defun make-record (date old-date title contents)
  "plist形式でデータを格納する"
  (list :date date :old-date old-date :title title :contents contents)) ; => MAKE-RECORD

(defun write-diary ()
  "プロンプトから問い合わせながらデータ入力できる機能"
  (make-record
   sun-date
   luna-date
   (prompt-read "title")
   (prompt-read2 "contents")))		; => WRITE-DIARY

(defun write-diaries ()
  "複数の日記データをプロンプトから書く機能"
  (loop (add-record (write-diary))
     (if (not (y-or-n-p "Another? [y/n]: "))
	 (return)))) ; => WRITE-DIARIES

(defun add-record (d)
  "データをデータベースへ追加する"
  (push d *db*))			; => ADD-RECORD

(defun dump-db ()
  "指定したデータベース情報を読みやすい形式で整形出力"
  (format t "~{~{~a:~10t~a~%~}~%~}" *db*)) ; => DUMP-DB

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

;;(defun where (&key date old-date title contents)
;;	"検索キーワードを指定する"
;;	#'(lambda (d)
;;			(and
;;			 (if date (equal (getf d :date) date) t)
;;			 (if old-date (equal (getf d :old-date) old-date) t)
;;			 (if title (equal (getf d :title) title) t)
;;			 (if contents (equal (getf d :contents) contents) t))))
;;-> where マクロをつくる。汎用性を高める。

(defun make-comparison-expr (field value)
  `(equal (getf d ,field) ,value))	; => MAKE-COMPARISON-EXPR

(defun make-comparisons-list (fields)
  (loop while fields
     collecting (make-comparison-expr (pop fields) (pop fields)))) ; => MAKE-COMPARISONS-LIST

(defmacro where (&rest clauses)
  `#'(lambda (d) (and ,@(make-comparisons-list clauses)))) ; => WHERE

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
             row) *db*)))		; => UPDATE

(defun delete-rows (keyword)
  "データーベースからレコードを削除する"
  (setf *db* (remove-if keyword *db*)))	; => DELETE-ROWS

(defclass table ()
  ((rows :accessor rows :initarg :rows :initform (make-rows))
   (schema :accessor schema :initarg :schema))) ; => #<STANDARD-CLASS COMMON-LISP-USER::TABLE>

(defparameter *default-table-size* 100)	; => *DEFAULT-TABLE-SIZE*

(defun make-rows (&optional (size *default-table-size*))
  (make-array size :adjustable t :fill-pointer 0)) ; => MAKE-ROWS

(defun day-of-week (day month year)
  "Returns the day of the week as an integer.Monday is 0.Unfortunately,
by definition, this function won't work for dates before January 1, 1900. "
  (nth-value
   6
   (decode-universal-time
    (encode-universal-time 0 0 0 day month year 0)
    0)))				; => DAY-OF-WEEK

(defun main ()
  (unwind-protect
   (write-diaries)
   (save-db "~/howm/junk/diary.db")))	; => MAIN

(main)					; =>



;; 実行ファイルの作成
(sb-ext:save-lisp-and-die
 (merge-pathnames
  (pathname "diary.lisp") (user-homedir-pathname))
 :toplevel #'main
 :executable t)				; =>
