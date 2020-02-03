(in-package #:yaktrak)

(defparameter *yak-file* "~/.yaks.sexp")

(defvar *yaks* nil)

(term:update-style-sheet '((:current :bold)))

(defun main (&optional (args *command-line-arguments*))
  (setf *yaks* (read-yaks))
  (flet ((new-yak () (list (mark-name (unmark-name (second args))))))
    (case (first args)
      ((nil "show") (display-yaks (second args)))
      ("new" (new-branch (new-yak)))
      ("push" (push-yak (new-yak)))
      ("add" (add-yak (new-yak)))
      (otherwise (display-help))))
    (write-yaks *yaks*))

(defun read-yaks ()
  (with-open-file (stream *yak-file* :if-does-not-exist nil)
    (when stream (read stream nil))))
    
(defun write-yaks (yaks)
  (call-with-staging-pathname
   *yak-file*
   (lambda (path)
     (with-open-file (stream path :direction :output :if-exists :overwrite)
       (write yaks :stream stream)))))

(defun unmark-name (name) (string-right-trim "*" name))

(defun mark-name (name) (concatenate 'string name "*"))

(defun display-yaks (&optional mode)
  (let ((tree
        (case mode
          ("branch" (todo))
          ("current" (todo))
          (otherwise *yaks*))))
    (term:u-list tree :mark-style :current)))

(defun new-branch (yak)
  (declare (type cons yak))
  (push yak *yaks*))

(defun push-yak (yak)
  (declare (type cons yak))
  yak)
  
(defun pop-yak ())

(defun add-yak (yak)
  (declare (type cons yak))
  yak)

(defun shave-yak ())

(defun todo ())

;; bit of a hack, there is no single root yak but we pretend there is like so
(defun root-yak () (cons nil *yaks*))

(defun yak-current-p (yak)
  (declare (type cons yak))
  (format t "yak-current-p: ~a~%" (eq (last-char (car yak)) #\*)))

(defun yak-parent-of-current-p (yak)
  (declare (type cons yak))
  (format t "yak-parent-of-current-p ~a~%" (find-if #'yak-current-p (cdr yak))))

(defun find-current-and-parent (&optional (yak (root-yak)))
  (declare (type cons yak))
  (format t "find-current-and-parent: ~a~%"
          (some (lambda (yak) (or (yak-current-p yak) (yak-parent-of-current-p yak))) (cdr yak))))

(defun display-help ()
  (format t "Usage: yaktrak [ACTION] [ARGUMENT]...

Note that all actions that involve adding yaks also make the new yak current.

basic actions:
  show [MODE]: display yak tree (default if no action specified), MODE can be:
    all (default): what it says on the tin
    branch: only the current branch (starting from the root)
    current: current with some surrounding context
  new ITEM: add a new top-level yak

stack-like actions:
  push ITEM: add an item as child of the current yak and set as current
  pop: remove current yak, setting current to parent

tree-like actions:
  add ITEM: add an item as a sibling of the current yak and set as current
  shave: remove current yak, setting current to previous sibling or parent
"))
