;; set my load path
(setq load-path (cons "~/lib/emacs/site-lisp" load-path))

(set-cursor-color "red")
;;(set-background-color "Cornsilk")
(display-time)

;; highlight current line
(global-hl-line-mode 1)

;; To customize the background color
(set-face-background 'hl-line "light green")
;; always use spaces
(setq-default indent-tabs-mode nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;Highlight trailing whitespace;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; excess whitespace is sloppy (where do I find valid colors?)
(setq-default show-trailing-whitespace t) ; color set by customization at end of file
(setq-default indicate-empty-lines t)
(add-hook 'before-save-hook 'delete-trailing-whitespace)

(custom-set-faces
 '(trailing-whitespace
   ((((class color)
      (background light))
     (:background "cyan")))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;End trailing whitescpace stuff ;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; flymake
;; disable gui popups for flymake
(setq flymake-gui-warnings-enabled nil)

(when (load "flymake" t)
 (defun flymake-pyflakes-init ()
   (let* ((temp-file (flymake-init-create-temp-buffer-copy
                             'flymake-create-temp-inplace))
             (local-file (file-relative-name
                          temp-file
                          (file-name-directory buffer-file-name))))
     (list "/usr/local/python/2.7.2/bin/pyflakes" (list local-file))))


 (add-to-list 'flymake-allowed-file-name-masks
              '("\\.py\\'" flymake-pyflakes-init)))

(require 'flymake-jshint)
 (add-hook 'javascript-mode-hook
          (lambda () (flymake-mode 1)))
(add-hook 'find-file-hook 'flymake-find-file-hook)

;;;;; xml-specific init-cleanup routines
;;;;; can't get xmlstar to build so define the program to run as true.
;;;;; this prevents emacs from hanging on the second open(x|ht)ml file.
(defun flymake-xml-init ()
  (list "true" (list "val" (flymake-init-create-temp-buffer-copy 'flymake-create-temp-inplace))))

(load-library "flymake-cursor")

;; Work around bug in flymake that causes Emacs to hang when you open a
;; docstring.
(delete '(" *\\(\\[javac\\]\\)? *\\(\\([a-zA-Z]:\\)?[^:(\t\n]+\\)\:\\([0-9]+\\)\:[ \t\n]*\\(.+\\)" 2 4 nil 5)
        flymake-err-line-patterns)

;; And the same for the emacs-snapshot in Hardy ... spot the difference.
(delete '(" *\\(\\[javac\\] *\\)?\\(\\([a-zA-Z]:\\)?[^:(        \n]+\\):\\([0-9]+\\):[  \n]*\\(.+\\)" 2 4 nil 5)
        flymake-err-line-patterns)

(delete '(" *\\(\\[javac\\] *\\)?\\(\\([a-zA-Z]:\\)?[^:(        \n]+\\):\\([0-9]+\\):[  \n]*\\(.+\\)" 2 4 nil 5)
        flymake-err-line-patterns)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; End Flymamke
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq auto-mode-alist
      (append '(("\\.txt$" . rst-mode)
                ("\\.rst$" . rst-mode)
                ("\\.rest$" . rst-mode)
                ("\\.wsgi$" . python-mode)
                ("\\.zcml$" . nxml-mode)
                ("\\.rdf$" . nxml-mode)                                                                         ("\\.rdf$" . nxml-mode)
                ("\\.rdfs$" . nxml-mode)
                ("\\.pt$" . nxml-mode)
                ("\\.cpt$" . nxml-mode)
                ("\\.cpy$" . python-mode)
                ("\\.py$" . python-mode)
                ("\\.js$" . js-mode)
                ("\\.json$" . js-mode)
                ("\\.text" . markdown-mode)
                ("\\.md" . markdown-mode)
                ) auto-mode-alist))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;; markdown
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(autoload 'markdown-mode "markdown-mode.el" "Major mode for editing Markdown files" t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;; pymacs, autocomplete, ropemacs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(autoload 'pymacs-apply "pymacs")
(autoload 'pymacs-call "pymacs")
(autoload 'pymacs-eval "pymacs" nil t)
(autoload 'pymacs-exec "pymacs" nil t)
(autoload 'pymacs-load "pymacs" nil t)
(add-to-list 'load-path "~/.emacs.d/vendor/pymacs-0.24-beta2")
(require 'pymacs)
(pymacs-load "ropemacs" "rope-")
(setq ropemacs-enable-autoimport t)

(require 'auto-complete-config)
(add-to-list 'ac-dictionary-directories "~/lib/emacs/site-lisp/ac-dict")
(ac-config-default)
(require 'auto-complete)
;;(global-auto-complete-mode t)

;; (when (require 'auto-complete nil t)
;; ;;  (require 'auto-complete-python)
;;   (require 'auto-complete-css)
;;   (require 'auto-complete-cpp)
;;   (require 'auto-complete-emacs-lisp)
;;   (require 'auto-complete-semantic)
;;   (require 'auto-complete-gtags)

(when (require 'auto-complete nil t)
  (global-auto-complete-mode t)
  (setq ac-auto-start 3)
  (setq ac-dwim t)
  (set-default 'ac-sources '(ac-source-abbrev ac-source-words-in-buffer ac-source-files-in-current-dir ac-source-symbols))
)
(add-to-list 'load-path "~/lib/emacs/python-mode/")
(setq py-install-directory "~/lib/emacs/python-mode")
(require 'python-mode)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;; Insert PDB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; handy M-s binding for quick python debugging.

(defun slinkp-pdb-set-trace ()  "Insert a set_trace() call after the previous line, maintaining indentation"  (interactive)
  (forward-line -1)
  (end-of-line)
  (insert "\n")
  (indent-according-to-mode)
  (insert "import pdb; pdb.set_trace()")
  (indent-according-to-mode)
)

(global-set-key [(meta s)] 'slinkp-pdb-set-trace)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;; End pdb
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun slinkp-doc-type ()
  "Insert a DTD call after the previous line, maintaining indentation"
  (interactive)
  (indent-according-to-mode)
  (insert "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">")
  (indent-according-to-mode)
)
(global-set-key [(super d)] 'slinkp-doc-type)


(defun slinkp-use-strict ()  "Insert a 'use strict'; entry after the previous line, maintaining indentation"  (interactive)
  (forward-line -1)
  (end-of-line)
  (insert "\n")
  (indent-according-to-mode)
  (insert "\"use strict\";")
  (indent-according-to-mode)
)
(add-hook 'js-mode-hook
   (lambda ()
   (local-set-key [(meta u)] 'slinkp-use-strict)
))


;(setq mac-command-modifier 'super)

;(global-set-key [(super z)] 'undo)


;; always end with newline
(setq require-final-newline t)

;; How to distinguish files with same name:
;; instead of adding a number, show part of directory path.
;; Options are 'forward, 'post-forward, and 'reverse.
(setq uniquify-buffer-name-style 'post-forward)
(require 'uniquify)

;;; recentf
(recentf-mode 1)
(global-set-key (kbd "C-x C-r") 'recentf-open-files)

; display line numbers in margin (fringe). Emacs 23 only.
(global-linum-mode 1) ; always show line numbers

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;; Ignore when listing (dired-x)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; don't show these in dired
;; Get dired to consider .pyc and .pyo files to be uninteresting
(add-hook 'dired-load-hook
  (lambda ()
    (load "dired-x")
  ))
(add-hook 'dired-mode-hook
  (lambda ()
    (setq dired-omit-files-p t)
    (setq dired-omit-files (concat dired-omit-files "\\|^\\..+$"))
  ))
(load "dired")
(setq dired-omit-extensions (append '(".pyc" ".pyo")
                             dired-omit-extensions))

(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(column-number-mode t)
 '(display-battery-mode t)
 '(display-time-mode t)
 '(espresso-indent-level 4)
 '(js2-auto-indent-p t)
 '(js2-bounce-indent-p t)
 '(js2-cleanup-whitespace t)
 '(py-pychecker-command "pychecker")
 '(py-pychecker-command-args (quote ("")))
 '(python-check-command "pychecker")
 '(safe-local-variable-values (quote ((encoding . utf-8))))
 '(save-place t nil (saveplace))
 '(show-paren-mode t)
 '(size-indication-mode t)
 '(transient-mark-mode t)
 '(uniquify-buffer-name-style (quote forward) nil (uniquify)))


;; magit
(require 'magit)

;;;Start server
(server-start)
