(in-package :cl-user)
(defpackage mblispweb.web
  (:use :cl
        :caveman2
        :mblispweb.config
        :mblispweb.view
        :mblispweb.db
        :datafly
        :sxql)
  (:export :*web*))
(in-package :mblispweb.web)

;; for @route annotation
(syntax:use-syntax :annot)

;;
;; Application

(defclass <web> (<app>) ())
(defvar *web* (make-instance '<web>))
(clear-routing-rules *web*)

;;
;; Routing rules
;;;Yi Ching
(defparameter *liang_yi* '(:阴 #\U+268B :阳 #\U+268A))
(defparameter *si_xiang* '(:老阳 #\U+268C :少阴 #\U+268D :少阳 #\U+268E :老阴 #\U+268F))

(defparameter yi (loop for i from 19904 to 19967 collect
                       (format nil "~a: ~a~%" (- i 19904) (subseq (char-name (code-char i)) (+ 4 (search "FOR" (char-name (code-char i)) :test #'string=))))))
(defparameter *gua_int* (loop for i from 19904 to 19967
                              collect i))
(defparameter *gua_eng_name* (loop for i from 19904 to 19967 collect
                                   (subseq (char-name (code-char i)) (+ 4 (search "FOR" (char-name (code-char i)) :test #'string=)))))
(defparameter *gua_chn_name* '(乾 坤 屯 蒙 需 訟 師 比 小畜 履 泰 否 同人 大有 謙 豫 隨 蠱 臨 觀 噬嗑 賁 剝 復 無妄 大畜 頤 大過 坎 離 鹹 恆 遁 大壯 晉 明夷 家人 睽 蹇  解 損 益 夬 姤 萃 升 困 井 革 鼎 震 艮 漸 歸妹 豐 旅 巽 兑 渙 節 中孚 小過 既濟 未濟))
(defparameter *gua_unichar* (mapcar #'princ-to-string (mapcar #'code-char *gua_int*)))
(defparameter *64_gua* (mapcar #'list *gua_int* *gua_unichar* *gua_chn_name* *gua_eng_name*))
(defroute "/" ()
  (render #P"index.html"
          (list :gua *64_gua*)))

;;(def-filter :getnum (val)
;;(- val 1990)

(defroute "/hi/:name" (&key name)
  (render #P"index.html"
          '(:name name)))

(defparameter songci (cl-store:restore #P"songci.text"))

;;;(defparameter sresult nil)
(defun cibyauth (auth)
  (loop for s in songci
        when (string= (cdadr s) auth)
        collect (cdar s) into sresult
        finally (return sresult)))
;;(import 'cl-markup:xhtml)
;;(defroute "/songci/byname/:name" (&key name)
  ;;(cl-markup:xhtml
   ;;(:head (:title (format nil "宋词汇总——~a" name)))
   ;;(:body (format nil "~{~a~}" (cibyauth name)))))

(import 'mblispweb.view:render)
(defroute "/songci/name/:name" (&key name)
  (render #P"songci.html"
          (list :name name :ci (cibyauth name))))

(defun byword (wd)
  (loop for l in songci collect
        (loop for c in (cdar l)
              when (search wd c)
              collect (format nil "~a~%~10@a~a~3@a~a~%~%" c "——" (cdadr l) " " (cdaddr l)) into sresult
              finally (return sresult))))
;;(import 'cl-markup:xhtml)
;;(defroute "/songci/byword/:word" (&key word)
  ;;(cl-markup:xhtml
   ;;(:head (:title (format nil "宋词汇总——~a" word)))
   ;;(:body (format nil "~{~a~}" (byword word)))))

(import 'mblispweb.view:render)
(defroute "/songci/word/:word" (&key word)
  (render #P"songci.html"
          (list :word word :ci (byword word))))

;;
;; Error pages

(defmethod on-exception ((app <web>) (code (eql 404)))
  (declare (ignore app))
  (merge-pathnames #P"_errors/404.html"
                   *template-directory*))
