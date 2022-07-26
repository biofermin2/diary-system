;;#!/usr/bin/sbcl  --noinform
                                        ; -*- mode: Lisp; coding:utf-8 -*-
;; 稼働していたものを変更する事にする。[2020-07-15 01:29:41]

#.(load "/home/hiro/howm/junk/utils.lisp") ; => T
(qload :trivial-shell :local-time)	   ; => (:TRIVIAL-SHELL :LOCAL-TIME)

;; Copyrightの表示
(copyright "diary-system" "dev2.1")	; =>
;; (:PROGRAM-NAME "diary-system" :VERSION "dev2.1" :COPYRIGHT "2020" :AUTHOR
;;  "Higashi, Hiromitsu" :LICENSE "MIT")

;; シェルをzshに変更 (デフォルトは "/bin/sh")
(setf trivial-shell:*bourne-compatible-shell* "/usr/bin/zsh") ; => "/usr/bin/zsh"
;; (let ((qdate (trivial-shell:shell-command "cut -f 2 -d: =(python -m ~/core/bin/qreki)")))
;; 	(format t "~A" qdate))								; => 2019年3月10日 2019年2月4日

(setf qdate (split " " (trivial-shell:shell-command "cut -f 2 -d: =(python ~/core/bin/qreki.py)"))) ; => ("2020年8月15日" "2020年6月26日")

(setf sun-date (car qdate))		; => "2020年8月15日"
(setf luna-date (trim (cadr qdate)))	; => "2020年6月26日"

;; setfで分割（エラー原因になっている）[2020-07-28 21:09:13]
;; (multiple-value-bind ()
;;     (let* ((qdate (split " " (trivial-shell:shell-command "cut -f 2 -d: =(python ~/core/bin/qreki.py)")))
;; 	   (sun (car qdate))
;; 	   (luna (cadr qdate)))
;;       (setf sun-date sun
;; 	    luna-date (trim luna))))	; => NIL

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

;; (defclass book ()
;;   ((author :initarg :author :initform "" :accessor author)
;;    (title :initarg :title :initform "" :accessor title)
;;    (year :initarg :year :initform 0 :accessor year))
;;   (:documentation "Describes a book"))	; => #<STANDARD-CLASS COMMON-LISP-USER::BOOK>

;; (defclass diary ()
;;   ((sun-date :initarg :sun-date :initform "" :accessor sun-date)
;;    (luna-date :initarg :luna-date :initform "" :accessor luna-date)
;;    (title :initarg :title :initform "" :accessor title)
;;    (contents :initarg :contents :initform "" :accessor contents))
;;   (:documentation "基本の日記システム")) ;=> #<STANDARD-CLASS COMMON-LISP-USER::DIARY>
                                        ;COMMON-LISP-USER::DIARY>


;; (defparameter *my-diary* nil)							;=> *MY-DIARY*
;; (setf *my-diary* (make-instance 'diary)) ;=> #<DIARY {100819E083}>
;; (class-of *my-diary*)											;=> #<STANDARD-CLASS COMMON-LISP-USER::DIARY>
;; (sun-date *my-diary*)											;=> ""
;; (setf *my-diary* (make-instance 'diary
;;                                 :sun-date sun-date
;;                                 :luna-date luna-date
;;                                 :title ""
;;                                 :contents "")) ;=> #<DIARY {1003D79CB3}>

;; (sun-date *my-diary*)													 ;=> "2019年4月6日"
;; (print-object *my-diary* *standard-output*)		 ;=> #<DIARY {1003D79CB3}>NIL

;; (setf ansi-commonlisp (make-instance 'book
;; 																		 :author "Paul Graham"
;; 																		 :title "ANSI Common Lisp"
;; 																		 :year 1995)) ; => #<BOOK {1005281563}>
;; (author ansi-commonlisp)													; => "Paul Graham"
;; (year ansi-commonlisp)														; => 1995


;; 構造体により日記システムの骨子を定義
;; タイトルは陰暦の日付にする
;; (defstruct diary
;; 	date
;; 	weather
;; 	contents
;; 	)																			;=> DIARY
;; ;; インスタンスの作成
;; (make-diary)														;=> #<DIARY {1006EAF143}>
;; 																				; :CONTENTS NIL)

;; ;; インスタンスの中身を見る
;; (describe (make-diary))									;=> #<DIARY {1006EB9133}>
;; ;;   [structure-object]

;; Slots with :INSTANCE allocation:
;;   DATE      = NIL
;;   WEATHER   = NIL
;;   CONTENTS  = NIL

;; (setf s-date (make-diary
;; 							:date l-date
;; 							:weather "晴"
;; 							:contents "今日はプログラミング三昧")) ; => #S(DIARY :DATE "2019年2月4日" :WEATHER "晴" :CONTENTS "今日はプログラミング三昧")



;; 現在の日付を求める
;; (multiple-value-bind (second
;;                       minute
;;                       hour
;;                       date
;;                       month
;;                       year
;;                       day-of-weak
;;                       daylight-p
;;                       time-zone)
;;     (get-decoded-time)
;;   (format nil "~0A-~0A-~0A" year month date)) ; => "2016-6-8"

;; (defvar me (make-person :name "東　洋光" :age 42))	; => ME
;; (defvar mei1 (make-person :name "東　照香" :age 9)) ; => MEI1
;; (defvar mei2 (make-person :name "東　澄乃" :age 6)) ; => MEI2


;; (with-slots (name age) me
;; 	(format t "I'm ~A. ~D years old." name age)) ; => I'm 東　洋光. 42 years old.NIL

;; (person-age me)													; => 42
;; (with-slots (age) me
;; 	(incf age))														; => 43
;; (person-age me)													; => 43
;; ;; defvarはdefparameterと違って基本的に一度定義すると追加で書き換えられない。
;; ;;しかし、これを見るとわかるが、with-slotsで年齢を一つ増加させる事が出来た。
;; ;; 結婚などで名前を書き換える時はどうしたらいいのだろうか？
;; ;; やってみよう。
;; (with-slots (name) mei1
;; 	(setf person-name "西 　照香"))				; => "西　照香"
;; (person-name mei1)											; => "東　照香"

;; ;;これは出来なかった。。。これでは結婚出来ないではないか！
;; ;; もう一度トライ
;; (with-slots (name) mei1
;; 	(setf (person-name mei1) "西　照香"))	; => "西　照香"
;; (person-name mei1)											; => "西　照香"
;; ;; 出来た！！！
;; ;; うまくやればdefvarでもこうやってスロット内容を変更出来る。
;; ;; そういう意味ではdefvarで統一した方が変なエラーが起きなくて済むような気がした。[2016-06-16 17:19:59]

;; (defmethod baz ((x integer) (y integer))
;; 	(format t "integer ~D, integer ~D~%" x y)) ; => #<STANDARD-METHOD COMMON-LISP-USER::BAZ (INTEGER INTEGER) {1005126503}>
;; (defmethod baz ((x integer) (y float))
;; 	(format t "integer ~D, float ~E~%" x y)) ; => #<STANDARD-METHOD COMMON-LISP-USER::BAZ (INTEGER FLOAT) {1004C8D963}>
;; (defmethod baz ((x float) (y float))
;; 	(format t "float ~E, float ~E~%" x y)) ; => #<STANDARD-METHOD COMMON-LISP-USER::BAZ (FLOAT FLOAT) {1004E302B3}>

;;;; diary.lisp version 1
;; (defun make-record (sun-date luna-date title contents)
;; 	"plist形式でデータを格納する"
;; 	(list :sun-date sun-date :luna-date luna-date :title title :contents contents)) ;=> MAKE-RECORD

;; (defun make-record (sun-date luna-date title contents)
;; 	"instanceでデータを格納する"
;; 	(*my-diary*))													;=> MAKE-RECORD

(defvar *interrupt-condition*
  ;; It seems abcl does not raise any conditions
  #+allegro 'excl:interrupt-signal
  #+ccl 'ccl:interrupt-signal-condition
  #+clisp 'system::simple-interrupt-condition
  #+ecl 'ext:interactive-interrupt
  #+sbcl 'sb-sys:interactive-interrupt
  #-(or allegro ccl clisp ecl sbcl) 'no-conditon-known) ; => *INTERRUPT-CONDITION*

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

(defun run ()
  (handler-case
      (while t
	 (funcall (in_closure)))
    (sb-kernel::interactive-interrupt (int)
				      (declare (ignorable int))
      (format t "caught sigint."))))	; => RUN

;; (defun write-content (str)
;;   "^cで処理の終了"
;;   (handler-case
;;       (with-output-to-string (str)
;; 	(print (unwind-protect (while t
;; 				 (read))) str))
;;     (sb-kernel::interactive-interrupt (int)
;;       (declare (ignorable int))
;;       (format t "caught sigint."))))	; => WRITE-CONTENT

(defun write-content (str)
  "^cで処理の終了"
  (with-handler-interrupt
      (with-output-to-string (str)
	(print (while t
		 (read)) str))))	; => WRITE-CONTENT

(let ((s nil))
  (defun in_closure ()
    "クロージャー内に文字列格納"
    (lambda ()
      (push (read) s)
      (princ s))))	     ; => IN_CLOSURE
;; usage:(funcall (in_closure))
;; 最終的にクロージャーの中身を保持しておきたい時は
;; (setf x (funcall (in_closure)))
;; とやってxに格納する。

(defun prompt-read (prompt)
  "プロンプト入力情報の読み込み"
  (format *query-io* "~a: " prompt)
  (force-output *query-io*)
  (read *query-io*))			; => PROMPT-READ

(defun prompt-read2 (prompt)
  "プロンプト入力情報の読み込みcontents用"
  (format *query-io* "~a: " prompt)
  (force-output *query-io*)
  (princ (funcall (run)) *query-io*))	; => PROMPT-READ2

(defun write-diary ()
  "プロンプトから問い合わせながらデータ入力できる機能"
  (make-record
   :sun sun-date
   :luna luna-date
   :title (prompt-read "title")
   :contents (mkstr (prompt-read2 "contents")))) ; => WRITE-DIARY
;;sun-date				; => "2020年7月27日"
;;luna-date				; => "2020年6月7日"
;;(prompt-read "title")			; => "-クロージャーを使ったテスト"
(prompt-read2 "contents")		; =>

(defun mkstr (&rest args)
  (with-output-to-string (s)
			 (dolist (a args) (princ a s)))) ; => MKSTR
(mkstr (funcall (in_closure)))				 ; => (AAA あああ AAA 3行目 もう1行、2行目です 試験的に書き込みます1 テスト書き込み２ 書き込み1 テスト したが、ちゃんとかきこめるだろうか?

(defun make-record (&key sun luna title contents)
  "plist形式でデータを格納する"
  `(,sun ,luna ,title ,contents))	; => MAKE-RECORD


;;(make-record :sun "2020-08" :luna "2020-07" :title "テスト" :contents '(これはテストの入力です)) ; => ("2020-08" "2020-07" "テスト" (これはテストの入力です))
;; => ("2020-08" "2020-07" "テスト" "これはテストの入力です")

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
