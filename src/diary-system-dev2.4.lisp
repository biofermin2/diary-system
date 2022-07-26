;;#!/usr/bin/sbcl  --noinform
                                        ; -*- mode: Lisp; coding:utf-8 -*-
;; 開発目標 [2020-08-15 17:42:24]
;; restartを使って入力を完了させるようにしたい。

;; 稼働していたものを変更する事にする。[2020-07-15 01:29:41]
(load "/home/hiro/howm/junk/utils.lisp") ; => T
(qload :cffi :trivial-shell :local-time) ; => (:CFFI :TRIVIAL-SHELL :LOCAL-TIME)

;; Copyrightの表示
(copyright "diary-system" "dev2.4")	; =>
;; (:PROGRAM-NAME "diary-system" :VERSION "dev2.4" :COPYRIGHT "2020" :AUTHOR
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

;;(defparameter *my-diary* nil)		; => *MY-DIARY*
;; (defmacro while (test &body body)
;;   `(do ()
;;        ((not ,test))
;;      ,@body))				; => WHILE

(defparameter cls-con nil)		; => CLS-CON
(defparameter cls-con2 nil)		; => CLS-CON2
(defparameter cls-con3 nil)		; => CLS-CON2

(setf cls-con (let ((s nil))
		(lambda () (push (read) s)))) ; => #<CLOSURE (LAMBDA ()) {100433D5FB}>
(setf cls-con3 (let ((s nil))
		 (lambda (x) (push x s)))) ; => #<CLOSURE (LAMBDA (X)) {100482A47B}>
;; (funcall cls-con3 'nil)			   ; => (NIL TEST1 TEST2 TEST1)
;; (reverse (funcall cls-con3 nil))	   ; => (TEST1 TEST2 TEST1 NIL NIL)

;;(apply #'concatenate 'string (reverse (funcall cls-cons3 nil))) ; =>

;; (funcall cls-con3 (read))		   ; => (TEST2 TEST1)
;; (funcall cls-con)			; => (TEST1)


;; (defparameter read-str nil)		      ; => READ-STR
;; (setf read-str (read-line))	      ; => "test1 test1 test1"
;; (defparameter con2 nil)		      ; => CON2

;; (setf con2 (let ((s nil))
;; 	     (lambda (r) (push r s))))	; => #<CLOSURE (LAMBDA (R)) {100352335B}>
;; (setf con2 read-str)			; => "test1 test1 test1"
;; (let ((s nil))
;;   (defun dicon ()
;;     (while t
;;       (push read-str s))))		; => DICON
;;  (defun dummy-function (x)
;;     (setq state 'running)
;;     (unless (numberp x) (throw 'abort 'not-a-number))
;;     (setq state (1+ x)))		; => DUMMY-FUNCTION
;;  (catch 'abort (dummy-function 1))	; => 2
;;  state					; => 2
;; (catch 'abort (dummy-function 'trash))	; => NOT-A-NUMBER
;; state					; => RUNNING
;;  (catch 'abort (unwind-protect (dummy-function 'trash)
;; 		 (setq state 'aborted))) ; => NOT-A-NUMBER
;; state					 ; => ABORTED
;; (defun bad-function()
;;   (error 'foo))				; => BAD-FUNCTION

;; (handler-case (bad-function)
;;   (foo () (funcall a))
;;   (bar () "somebody signaled bar!"))	; =>
;; (defparameter *special* :old)		; => *SPECIAL*
;; (defun div (x y)
;;   (let ((*special* :new))
;;     (catch 'catch-tag
;;       (/ x y))))			; => DIV

;; (defun test (a b)
;;   (handler-case
;;       (div a b)
;;     (type-error (condition)
;; 		(format *error-output*
;; 			"oops, ~S should have been of type ~A."
;; 			(type-error-datum condition)
;; 			(type-error-expected-type condition))
;; 		*special*)
;;     (division-by-zero ()
;; 		      (format *error-output*
;; 			      "this might create black holes!")
;; 		      (throw 'catch-tag -1)))) ; => TEST

;; (defvar *interrupt-condition*
;;   ;; It seems abcl does not raise any conditions
;;   #+allegro 'excl:interrupt-signal
;;   #+ccl 'ccl:interrupt-signal-condition
;;   #+clisp 'system::simple-interrupt-condition
;;   #+ecl 'ext:interactive-interrupt
;;   #+sbcl 'sb-sys:interactive-interrupt
;;   #-(or allegro ccl clisp ecl sbcl) 'no-conditon-known) ; => *INTERRUPT-CONDITION*

;; 使用例
;; (defun main ()
;;   (start-app :port 9003) ;; our start-app, for example clack:clack-up
;;   ;; let the webserver run.
;;   ;; warning: hardcoded "hunchentoot".
;;   (handler-case (bt:join-thread (find-if (lambda (th)
;;                                             (search "hunchentoot" (bt:thread-name th)))
;;                                          (bt:all-threads)))
;;     ;; Catch a user's C-c
;;     (#+sbcl sb-sys:interactive-interrupt
;;       #+ccl  ccl:interrupt-signal-condition
;;       #+clisp system::simple-interrupt-condition
;;       #+ecl ext:interactive-interrupt
;;       #+allegro excl:interrupt-signal
;;       () (progn
;;            (format *error-output* "Aborting.~&")
;;            (clack:stop *server*)
;;            (uiop:quit)))
;;     (error (c) (format t "Woops, an unknown error occured:~&~a~&" c))))

;;;
;; (defmacro with-handle-interrupt (&body body)
;;   `(handler-case
;;        #-ccl(progn
;;               ,@body)
;;        #+ccl (let ((ccl:*break-hook* (lambda (condition hook)
;;                                        (declare (ignore hook))
;;                                        (error condition))))
;;                ,@body)
;;        (#.*interrupt-condition* (c)
;; 				(handle-interrupt c))))	; => WITH-HANDLE-INTERRUPT
;; (with-handle-interrupt (funcall a))			; => (AAA1 END A3 A2 A1 A TEST2 TEST1)

;; (setf a (let ((s nil))
;; 	  (lambda () (while (not (eq (read) nil))
;; 		       (push (read) s)) s))) ; => #<CLOSURE (LAMBDA ()) {10054949BB}>
;; (mapcar 'funcall
;; 	(loop for i below 10
;; 	      collect (let ((j i))
;; 			(lambda () (read))))) ; => (AAA1 AAAA3 3DDKFJA 4 JLJFAL5 FJLAJ6 FAJDFA7 DAKあああ8 あいあかいえ9 あいあいあか10)
;; (setf b '(aaa bbb ccc))		; => (AAA BBB CCC)
;; (car b)				; => AAA
;; (cdr b)				; => (BBB CCC)
;; (mapcar 'funcall
;; 	(loop for i below 10
;; 	      collect (let ((j (read)))
;; 			(lambda () j)))) ; =>
;; (mapcar 'funcall
;; 	(while (not (eq (read) nil))
;; 	  (let ((j (read)))
;; 	    (lambda () (princ j)))))	; => NIL

;; (defun push-closure ()
;;   (when t
;;     (loop (restart-case (progn (funcall a)
;; 			       (return))
;; 			(setf b (funcall a)))))) ; => PUSH-CLOSURE

;; (defun add-widget (database widget)
;;   (cons widget database))		; => ADD-WIDGET

;; (defparameter *database* nil)		; => *DATABASE*

;; (defun main-loop ()
;;   (loop (princ "Please enter the name of a new widget:")
;; 	(setf *database* (add-widget *database* (read)))
;; 	)) ; => MAIN-LOOP

;; (defun run ()
;;   (handler-case
;;       (loop (funcall a)
;;        (if (eq (read) nil)
;; 	   (return)))
;;     (sb-kernel::interactive-interrupt (int)
;; 				      (declare (ignorable int))	    ; =>
;; 				      (format t "caught sigint")))) ; => RUN

;; (defun run ()
;;   (loop (funcall a)
;; 	(setf b (funcall a))
;; 	(if (eq (read) nil)
;; 	    (return))))					; => RUN

;; (defun run ()
;;   (while (not (eq (read) nil))
;;     (funcall a)
;;     (setf b (funcall a)))
;;   b)

;; run3
;; (defun run ()
;;   (loop
;;    (funcall cls-con)
;;    (setf cls-con2 (funcall cls-con))
;;    (if (eq (car cls-con2) nil)
;;     (return)))
;;   (mapcar #'(lambda (x) (prin1 x))
;; 	  (reverse cls-con2)))		; => RUN

;; run4
;; (defun compose (&rest fns)
;;   (if fns
;;       (let ((fn1 (car (last fns)))
;; 	    (fns (butlast fns)))
;; 	#'(lambda (&rest args)
;; 	    (reduce #'funcall fns
;; 		    :from-end t
;; 		    :initial-value (apply fn1 args))))
;;     #'identitiy))			; => COMPOSE


;; (setf l '(hoge foo bar))		; => (HOGE FOO BAR)
;; (setf l2 '("hoge" "foo" "bar"))		; => ("hoge" "foo" "bar")
;; ;; (mapcar #'(lambda (x) (concatenate 'string x)) '("hoge" "foo")) ; => ("hoge" "foo")
;; (with-output-to-string (out)
;;   (mapcar #'prin1 l))			; => HOGEFOOBAR""
;; (format t "~{~A~}" l)			   ; => HOGEFOOBARNIL
;; (format t "~{~A~}" l2)			   ; => hogefoobarNIL
;; (apply #'concatenate 'string l)		; =>
;; (apply #'concatenate 'string l2)	; => "hogefoobar"

;; (compose #'list #'1+) ; => #<CLOSURE (LAMBDA (&REST ARGS) :IN COMPOSE) {1001D989DB}>

;; (defun read-input ()
 ;;   (list (read-line) (read-line)))	; => READ-INPUT
 ;;trivial-signal
 ;; (signal-handler-bind ((:int  (lambda (signo)
 ;;                                (declare (ignorable signo))
 ;;                                ...handler...)))
 ;;   ...body...)

 ;; (defmacro set-signal-handler (signo &body body)
 ;;   (let ((handler (gensym "HANDLER")))
 ;;     `(progn
 ;;        (cffi:defcallback ,handler :void ((signo :int))
 ;;          (declare (ignore signo))
 ;;          ,@body)
 ;;        (cffi:foreign-funcall "signal" :int ,signo :pointer (cffi:callback ,handler))))) ; => SET-SIGNAL-HANDLER

 ;; (set-signal-handler 2
 ;;   (format t "Quitting lol!!!11~%")
 ;;   ;; fictional function that lets the app know to quit cleanly (don't quit from callback)
 ;;   (setf b (funcall a))
 ;;   )			    ; =>
 ;; ;; うまく掴みにいって離さない。[2020-07-31 10:47:51]
 ;; 括弧をはずす　flattanと一緒。
 ;; (defun squash (tree)
 ;;   (if (null tree)
 ;;       nil
 ;;     (if (atom tree)
 ;; 	 (list tree)
 ;;       (append (squash (car tree)) (squash (cdr tree)))
 ;;       )))				; => SQUASH
;; run4
;; (defun run ()
;;   "nilが出るまで、クロージャーに文字入力し、最終的に文字列を逆順に変換し出力"
;;   (loop
;;    (funcall cls-con)
;;    (setf cls-con2 (funcall cls-con))
;;    (if (eq (car cls-con2) nil)
;;     (return)))
;;   (mapcar #'prin1 (reverse cls-con2)))	; => RUN
;; run5

(defun run ()
  (loop
   (setf st1 (read))
   (setf c1 (funcall cls-con3 st1))
   (when (null st1) (return)))
  (apply #'concatenate 'string (mapcar #'string (reverse (cdr c1))))) ; => RUN
;; (setf a '(a b c))			; => (A B C)
;; (setf b '(x y z))			; => (X Y Z)
;; (setf a (nconc b a))			; => (X Y Z A B C)
;; a					; => (X Y Z A B C)

;; (defun restart-process ()
;;   (restart-case (run)
;; 		(use-value (value)
;; 			   :report "Use a value."
;; 			   :interactive (lambda ()
;; 					  (format t "New value: ")
;; 					  (list (read)))
;; 			   value)
;; 		(ignore ()
;; 			:report "Ignore..."
;; 			nil)))		; => RESTART-PROCESS
;; (handler-bind ((error
;; 		(lambda (c)
;; 		  (declare (ignore c))
;; 		  (invoke-restart 'use-value nil))))
;;   (restart-process))			; =>

;; (handler-bind ((error
;; 		(lambda (c)
;; 		  (declare (ignore c))
;; 		  (invoke-restart 'ignore))))
;;   (restart-process))			; => NIL

 (defun prompt-read (prompt)
   "プロンプト入力情報の読み込み"
   (format *query-io* "~a: " prompt)
   (force-output *query-io*)
   (read-line *query-io*))			; => PROMPT-READ


 ;;クロージャーの内容を括弧を外した状態で入力順で表示
 ;; (let ((cls-con2 (funcall cls-con)))
 ;;   (mapcar (lambda(x)(string x))
 ;; 	  (reverse cls-con2)))		; => ("TEST8" "TEST9" "TEST10" "TEST11" "
 ;; (let ((b (funcall a)))
 ;;   (mapcar (lambda(x)(prin1 x))
 ;; 	  (reverse b)))

 ;; (defun prompt-read4 (prompt)
 ;;   "プロンプト入力情報の読み込みcontents用"
 ;;   (format *query-io* "~a: " prompt)
 ;;   (force-output *query-io*)
 ;;   (while (not (eq (read) nil)) (mkstr (mapcar (lambda (x) (prin1 x))
 ;; 					       (reverse (funcall a)))))) ;

(defun prompt-read5 (prompt)
   "プロンプト入力情報の読み込みcontents用"
   (format *query-io* "~a: " prompt)
   (force-output *query-io*)
   (restat-case (run)
		(continue () :interactive
			  (lambda () (apply #'concatenate 'string
					    (mapcar #'string (reverse (cdr c1)))))))) ; => PROMPT-READ5

;; (defun no-paren (lst)
;;   (if (not lst)
;;       (car lst)
;;     (no-paren (cdr lst))))		; => NO-PAREN

;; (setf l '(hoge foo bar))		; => (HOGE FOO BAR)
;; (defun f (x)
;;   (loop (not (car x))
;; 	(princ (car x))
;; 	(return))
;;   (f (cdr x)))				; => F
;; (f l)					; =>
;; (mapcar #'car l)			; =>

;; ((lambda (x) (prin1 x)) l)		; => (HOGE FOO BAR)(HOGE FOO BAR)
;; (mapcar #'pop l)			; =>
;; (concatenate 'string l)			; =>
;; (coerce l 'string)			; =>
;; (concatenate)
;; (mapcar #'prin1 l)			; => ABC(A B C)
;; (car l)					; => A
;; (cdr l)					; => (B C)
;; (no-paren l)				; => NIL
;; (no-paren '(nil c b a))			; => NIL

;; (no-paren b)		 ; =>
;; ;; 末尾再帰
;; (defun f (ls &optional (n 0))
;;   (if (not ls)
;;       n
;;     (f (cdr ls) (+ 1 n))))		; => F
;; (f '(a b c))				; => 3
;; (defun add-widget(database widget)
;;   (cons widget database))		; => ADD-WIDGET
;;(cons 'd '(c b a))			; => (D C B A)
;; (let ((db nil))
;;   (setf b
;; 	(lambda () (cons (read) db))))	; => #<FUNCTIONp (LAMBDA ()) {1001D325EB}>

;; (defparameter *database* nil)		; => *DATABASE*

;; (defun main-loop ()
;;   (loop (princ "Please enter the name of a new widget:")
;; 	(setf *database* (add-widget *database* (read)))
;; 	(format t "The database contains the following: ~a~%" *database*))) ; => MAIN-LOOP
;; (main-loop)								    ;
;; *database*								    ; => (ばなな みかん りんご りんご MERON NASHI BANANA MIKAN RINGO)
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
     (if (not (y-or-n-p "Another? [y/n]: ")) (return)))) ; => WRITE-DIARIES

;; (defun mkstr (&rest args)
;;   (with-output-to-string (s)
;; 			 (dolist (a args) (princ a s)))) ; => MKSTR
;; sun-date						 ; => "2020年7月29日"
;; (mkstr sun-date)					 ; => "2020年7月29日"

;; (defun make-record (&key sun luna title contents)
;;   "plist形式でデータを格納する"
;;   `(:sun ,sun :luna ,luna :title ,title :contents ,contents)) ; => MAKE-REC

;;(make-record :sun "2008" :luna "2233" :title "test" :contents "tes1") ; => (:SUN "2008" :LUNA "2233" :TITLE "test" :CONTENTS "tes1")



;; (defun dump-db ()
;;   "指定したデータベース情報を読みやすい形式で整形出力"
;;   (format t "~{~{~a:~10t~a~%~}~%~}" *db*)) ; => DUMP-DB

(defun save-db (filename)
  "データベースの名前付け保存"
  (with-open-file (out filename
                       :direction :output
                       :if-exists :append
                       :if-does-not-exist :create)
    (with-standard-io-syntax
      (print *db* out))))		; => SAVE-DB

;; (defun load-db (filename)
;;   "データベースの読み込み"
;;   (with-open-file (in filename)
;;     (with-standard-io-syntax
;;       (setf *db* (read in)))))		; => LOAD-DB

;; (defun select (keyword)
;;   "keywordに沿ってデータを抽出選択する"
;;   (remove-if-not keyword *db*))		; => SELECT

;; (defun make-comparison-expr (field value)
;;   `(equal (getf d ,field) ,value))

;; (defun make-comparisons-list (fields)
;;   (loop while fields
;;      collecting (make-comparison-expr (pop fields) (pop fields))))

;; (defmacro where (&rest clauses)
;;   `#'(lambda (d) (and ,@(make-comparisons-list clauses))))

;;(select (where :title "test"))					; => NIL

;; (defun update (keyword &key date old-date title contents)
;;   "データーベースの更新"
;;   (setf *db*
;;         (mapcar
;;          #'(lambda (row)
;;              (when (funcall keyword row)
;;                (if date (setf (getf row :title) title))
;;                (if old-date (setf (getf row :old-date) old-date))
;;                (if title (setf (getf row :title) title))
;;                (if contents (setf (getf row :contents) contents)))
;;              row) *db*)))

;; (defun delete-rows (keyword)
;;   "データーベースからレコードを削除する"
;;   (setf *db* (remove-if keyword *db*)))

;; (defclass table ()
;;   ((rows :accessor rows :initarg :rows :initform (make-rows))
;;    (schema :accessor schema :initarg :schema)))

;; (defparameter *default-table-size* 100)

;; (defun make-rows (&optional (size *default-table-size*))
;;   (make-array size :adjustable t :fill-pointer 0))

;; (defun day-of-week (day month year)
;;   "Returns the day of the week as an integer.Monday is 0.Unfortunately,
;; by definition, this function won't work for dates before January 1, 1900. "
;;   (nth-value
;;    6
;;    (decode-universal-time
;;     (encode-universal-time 0 0 0 day month year 0)
;;     0)))
					; => DAY-OF-WEEK
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
