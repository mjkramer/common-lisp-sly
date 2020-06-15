(defun spacemacs//sly-helm-source (&optional table)
  (or table (setq table sly-lisp-implementations))
  `((name . "Sly")
    (candidates . ,(mapcar #'car table))
    (action . (lambda (candidate)
                (car (helm-marked-candidates))))))

(defun spacemacs/helm-sly ()
  (interactive)
  (let ((command (helm :sources (spacemacs//sly-helm-source))))
    (and command (sly (intern command)))))

;; Evil integration

(defun spacemacs/sly-eval-sexp-end-of-line ()
  "Evaluate current line."
  (interactive)
  (move-end-of-line 1)
  (sly-eval-last-expression))

;; Functions are taken from the elisp layer `eval-last-sexp' was replaced with
;; its sly equivalent `sly-eval-last-expression'

(defun spacemacs/cl-eval-current-form ()
  "Find and evaluate the current def* or set* command.
Unlike `eval-defun', this does not go to topmost function."
  (interactive)
  (save-excursion
    (search-backward-regexp "(def\\|(set")
    (forward-list)
    (call-interactively 'sly-eval-last-expression)))


(defun spacemacs/cl-eval-current-form-sp (&optional arg)
  "Call `eval-last-sexp' after moving out of one level of
parentheses. Will exit any strings and/or comments first.
An optional ARG can be used which is passed to `sp-up-sexp' to move out of more
than one sexp.
Requires smartparens because all movement is done using `sp-up-sexp'."
  (interactive "p")
  (require 'smartparens)
  (let ((evil-move-beyond-eol t))
    ;; evil-move-beyond-eol disables the evil advices around eval-last-sexp
    (save-excursion
      (let ((max 10))
        (while (and (> max 0)
                    (sp-point-in-string-or-comment))
          (decf max)
          (sp-up-sexp)))
      (sp-up-sexp arg)
      (call-interactively 'sly-eval-last-expression))))


(defun spacemacs/cl-eval-current-symbol-sp ()
  "Call `eval-last-sexp' on the symbol around point.
Requires smartparens because all movement is done using `sp-forward-symbol'."
  (interactive)
  (require 'smartparens)
  (let ((evil-move-beyond-eol t))
    ;; evil-move-beyond-eol disables the evil advices around eval-last-sexp
    (save-excursion
      (sp-forward-symbol)
      (call-interactively 'sly-eval-last-expression))))

(when (configuration-layer/package-usedp 'sly)
  (spacemacs|define-transient-state common-lisp-navigation
    :title "Common Lisp Navigation Transient State"
    :doc "

^^Definitions                           ^^Compiler Notes             ^^Stickers
^^^^^^─────────────────────────────────────────────────────────────────────────────────────
[_g_] Jump to definition                [_n_] Next compiler note     [_s_] Next sticker
[_G_] Jump to definition (other window) [_N_] Previous compiler note [_S_] Previous sticker
[_b_] Pop from definition

[_q_] Exit
"
  :foreign-keys run
  :bindings
  ("g" sly-edit-definition)
  ("G" sly-edit-definition-other-window)
  ("b" sly-pop-find-definition-stack)
  ("n" sly-next-note)
  ("N" sly-previous-note)
  ("s" sly-stickers-next-sticker)
  ("S" sly-stickers-prev-sticker)
  ("q" nil :exit t)))
