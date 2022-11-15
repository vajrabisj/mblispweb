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

(defroute "/" ()
  (render #P"index.html"))

(defroute "/hi/:name" (&key name)
  (render #P"index.html"
          (list :name (format nil "你好，~a！欢迎回来！" name))))

(defparameter songci (cl-store:restore #P"songci.txt"))
;;;(defparameter sresult nil)
(defun cibyauth (auth)
  (loop for s in songci
        when (string= (cdadr s) auth)
        collect (cdar s) into sresult
        finally (return sresult)))
(import 'cl-markup:xhtml)
(defroute "/songci/byname/:name" (&key name)
  (cl-markup:xhtml
   (:head (:title (format nil "宋词汇总——~a" name)))
   (:body (format nil "~{~a~}" (cibyauth name)))))

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
(import 'cl-markup:xhtml)
(defroute "/songci/byword/:word" (&key word)
  (cl-markup:xhtml
   (:head (:title (format nil "宋词汇总——~a" word)))
   (:body (format nil "~{~a~}" (byword word)))))

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
