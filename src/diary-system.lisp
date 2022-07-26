(ql:quickload :trivial-shell :silent t)	 ; => (:TRIVIAL-SHELL)
(load "/home/hiro/howm/junk/utils.lisp") ; => T

;; シェルをzshに変更 (デフォルトは "/bin/sh")
(setf trivial-shell:*bourne-compatible-shell* "/usr/bin/zsh") ; => "/usr/bin/zsh"
(let ((qdate (trivial-shell:shell-command "cut -f 2 -d: =(python -m ~/core/bin/qreki)")))
  (format t "~A" qdate))		; => NIL
					; => 2018年4月30日 2018年3月15日

;; 構造体により日記システムの骨子を定義
;; タイトルは陰暦の日付にする
(defstruct diary
  date
  weather
  contents
  )													 ; => DIARY
;; インスタンスの作成
;; (make-diary)				; =>
;; 					; :CONTENTS NIL)

;; インスタンスの中身を見る
;; (describe (make-diary))
					; => #S(DIARY :DATE NIL :WEATHER NIL :CONTENTS NIL)
;;   [structure-object]

;; Slots with :INSTANCE allocation:
;;   DATE      = NIL
;;   WEATHER   = NIL
;;   CONTENTS  = NIL


(make-diary
 :date sun-date
 :weather "晴"
 :contents "今日はプログラミング三昧")	; => #S(DIARY :DATE "2017年9月11日" :WEATHER "晴" :CONTENTS "今日はプログラミング三昧")
(qdate)																	; =>
qdate																																	; => "2016年5月4日"



;; 現在の日付を求める
(multiple-value-bind (second
                      minute
                      hour
                      date
                      month
                      year
                      day-of-weak
                      daylight-p
                      time-zone)
    (get-decoded-time)
  (format nil "~0A-~0A-~0A" year month date)) ; => "2016-6-8"

(setf sun-date (multiple-value-bind (second
				     minute
				     hour
				     date
				     month
				     year
				     day-of-weak
				     daylight-p
				     time-zone)
		   (get-decoded-time)
		 (format nil "~A年~A月~A日" year month date))) ; => "2017年9月11日"

sun-date		 ; => "2017年9月11日"
(make-diary)														; => #S(DIARY :SUN-DATE NIL :LUNA-DATE NIL :WEATHER NIL :CONTENTS NIL)
(describe (make-diary))									; => #S(DIARY :SUN-DATE NIL :LUNA-DATE NIL :WEATHER NIL :CONTENTS NIL)
;; [structure-object]

;; Slots with :INSTANCE allocation:
;;   SUN-DATE   = NIL
;;   LUNA-DATE  = NIL
;;   WEATHER    = NIL
;; CONTENTS   = NIL
;;; 陰暦を求める

(defmethod baz ((x integer) (y integer))
  (format t "integer ~D, integer ~D~%" x y)) ; => #<STANDARD-METHOD COMMON-LISP-USER::BAZ (INTEGER INTEGER) {1005126503}>
(defmethod baz ((x integer) (y float))
  (format t "integer ~D, float ~E~%" x y)) ; => #<STANDARD-METHOD COMMON-LISP-USER::BAZ (INTEGER FLOAT) {1004C8D963}>
(defmethod baz ((x float) (y float))
  (format t "float ~E, float ~E~%" x y)) ; => #<STANDARD-METHOD COMMON-LISP-USER::BAZ (FLOAT FLOAT) {1004E302B3}>

(baz 1 2)																; => integer 1, integer 2
(baz 1 2.0)															; => integer 1, float 2.e+0
(baz 1.0 2.0)														; => float 1.e+0, float 2.e+0
(type-of "あいう")											; => (SIMPLE-ARRAY CHARACTER (3))
(type-of "abc")													; => (SIMPLE-ARRAY CHARACTER (3))
(type-of "あ")													; => (SIMPLE-ARRAY CHARACTER (1))
(type-of "a")														; => (SIMPLE-ARRAY CHARACTER (1))
;;; lambdaの短縮表記
;; エラーバージョン
;; (defmacro ^ ((&rest parameter) &body body)
;; 	`(lambda ,parameter ,@body))							; =>

;; ((^ (x y) (+ x y)) 1 2)									; =>
;; 正解バージョン
(let ((r (copy-readtable nil)))
  (defun read-symbol (stream)
    (let ((*readtable* r))
      (read-preserving-whitespace stream)))) ; => READ-SYMBOL

(defun symbol-reader-macro-reader (stream char)
  (unread-char char stream)
  (let* ((s (read-symbol stream))
	 (f (get s 'symbol-reader-macro)))
    (if f (funcall f stream s) s)))			; => SYMBOL-READER-MACRO-READER

(set-macro-character #\^ 'symbol-reader-macro-reader t) ; => T

(setf (get '^ 'symbol-reader-macro)
      #'(lambda (stream symbol)
	  (declare (ignore stream symbol))
	  'cl:lambda))									; => #<FUNCTION (LAMBDA (STREAM SYMBOL)) {1004B180AB}>

((^ (x y) (+ x y)) 1 2)									; => 3

(ql:quickload :diary-system)						; => To load "diary-system":

;;;; diary.lisp version 1
(defun make-record (date old-date title contents)
  "plist形式でデータを格納する"
  (list :date date :old-date old-date :title title :contents contents))

(defvar *db* nil "一時データ格納領域の定義")

(defun add-record (d)
  "データをデータベースへ追加する"
  (push d *db*))

(defun dump-db ()
  "指定したデータベース情報を読みやすい形式で整形出力"
  (format t "~{~{~a:~10t~a~%~}~%~}" *db*))

(defun prompt-read (prompt)
  "プロンプト入力情報の読み込み"
  (format *query-io* "~a: " prompt)
  (force-output *query-io*)
  (read-line *query-io*))

(defun write-diary ()
  "プロンプトから問い合わせながらデータ入力できる機能"
  (make-record
   (timestamp);date
   (luna-date)
   (prompt-read "title")
   (prompt-read "contents")))						; => WRITE-DIARY

(defun write-diaries ()
  "複数の日記データをプロンプトから書く機能"
  (loop (add-record (write-diary))
     (if (not (y-or-n-p "Another? [y/n]: ")) (return))))

(defun save-db (filename)
  "データベースの名前付け保存"
  (with-open-file (out filename
		       :direction :output
		       :if-exists :append
		       :if-does-not-exist :create)
    (with-standard-io-syntax
      (print *db* out))))

(defun load-db (filename)
  "データベースの読み込み"
  (with-open-file (in filename)
    (with-standard-io-syntax
      (setf *db* (read in)))))

;; (defun timestamp ()
;; 	"現在日付の取得"
;;        (multiple-value-bind (s m h dd mm yy)
;;            (decode-universal-time (get-universal-time))
;; ;         (format nil "~4,'0D-~2,'0D-~2,'0D ~2,'0D:~2,'0D:~2,0D" yy mm dd h m s)))
;;          (format nil "~4,'0D-~2,'0D-~2,'0D" yy mm dd)))
(defun timestamp ()
  "現在日付の取得"
  (multiple-value-bind (s m h dd mm yy)
      (decode-universal-time (get-universal-time))
    (declare (ignore s m h));これをつけておかないと取得した引数を使ってないという警告が出る。
;;         (format nil "~4,'0D-~2,'0D-~2,'0D ~2,'0D:~2,'0D:~2,0D" yy mm dd h m s)))
    (format nil "~4,'0D-~2,'0D-~2,'0D" yy mm dd))) ; => TIMESTAMP

(timestamp)															; => "2019-02-16"


(ql:quickload :trivial-shell)						; => To load "trivial-shell":
(ql:quickload :split-sequence)					; => To load "split-sequence":


;; (defun old-timestamp ()
;; 	"旧暦日付の取得"
;; 	(multiple-value-bind (sun-date luna-date)
;; 			(split-sequence:split-sequence #\Space
;; 																		 (trivial-shell:shell-command "/usr/bin/python -m /home/hiro/core/bin/qreki"))
;; 		(declare (ignore sun-date));使わない変数をignoreすると警告が出ない。
;; 		(princ sun-date)))				 ; => OLD-TIMESTAMP

(defun luna-date ()
  "旧暦日付の取得"
  (let ((dates (split-sequence:split-sequence #\Space
					      (trivial-shell:shell-command
					       "/usr/bin/python -m /home/hiro/core/bin/qreki"))))
    (prin1 (cadr dates))))							; =>
(luna-date)															; =>
;; (luna-date)															; => 2019年1月12日

;; (car (old-timestamp))										; => (2019年2月16日 2019年1月12日
;; )"2019年2月16日"
;; (cdr (old-timestamp))										; => (2019年2月16日 2019年1月12日
;; )("2019年1月12日
;; ")
;; 以下はelisp.common lispでは使えない
;; 数値だけ抽出
;; (defun nums-string (str)
;;   (let ((s 0) res)
;;     (while (setq s (string-match "[0-9]+" str s))
;;       (push (parse-integer (match-string 0)) res)
;;       (incf s (length (match-string 0))))
;;     res))																; => NUMS-STRING
;; (nums-string "2019年2月14日")						; =>

;; (nums-string (get-clipboard-data))			; =>

;; (subseq (old-timeSTAMP) 3 13)						; => "2019年2月14日"
;; (subseq (old-timeSTAMP) 16 26)					; => "2019年1月10日"
;; (map 'string #'(lambda (x) (princ x)) "hogehoge") ; => hogehoge"hogehoge"
;; (car '("a" "b"))															; => "a"

(defun select (keyword)
  "keywordに沿ってデータを抽出選択する"
  (remove-if-not keyword *db*))

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

;;(select (where :title "test"))

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
  (write-diaries)
  (save-db "~/howm/junk/diary.db"))

(main)
;;(day-of-week 13 06 2014)								; => 4

;; (defun day-of-week (day month year)
;;   "Returns the day of the week as an integer.
;; Sunday is 0. Works for years after 1752."
;;   (let ((offset '(0 3 2 5 0 3 5 1 4 6 2 4)))
;;     (when (< month 3)
;; 			(decf year 1))
;;     (mod
;;      (truncate (+ year
;;                   (/ year 4)
;;                   (/ (- year)
;;                      100)
;;                   (/ year 400)
;;                   (nth (1- month) offset)
;;                   day
;;                   -1))
;;      7)))																; => DAY-OF-WEEK
;; (decode-universal-time (get-universal-time)) ; => 52
;; 7
;; 22
;; 14
;; 2
;; 2019
;; 3
;; NIL
;; -9
(defvar my-string "今日のtodayはいい天気") ; => MY-STRING
(find-if #'standard-char-p my-stRING)			 ; => #\t
(position #'standard-char-p my-string)		 ; => NIL
(map 'list (lambda))

;; 英語の処理
(defun en-p (char)
  (while (standard-char-p char)
    (push char lst))
  (list lst lst))

(list '(a b c) '(d e f))								; => ((A B C) (D E F))
