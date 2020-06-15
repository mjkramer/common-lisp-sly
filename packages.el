(defconst common-lisp-sly-packages
  '(auto-highlight-symbol
    (common-lisp-snippets :requires yasnippet)
    evil
    evil-cleverparens
    ;; ggtags
    ;; counsel-gtags
    helm
    ;; helm-gtags
    xterm-color
    popwin
    parinfer
    company
    rainbow-identifiers
    smartparens
    (sly :requires smartparens)
    (sly-mrepl :requires sly :location built-in)
    (sly-macrostep :requires (sly macrostep))
    (sly-repl-ansi-color :requires sly)
    (sly-quicklisp :requires sly)
    (sly-asdf :requires sly)))

(defun common-lisp-sly/post-init-auto-highlight-symbol ()
  (with-eval-after-load 'auto-highlight-symbol
    (add-to-list 'ahs-plugin-bod-modes 'lisp-mode)))

(defun common-lisp-sly/init-common-lisp-snippets ())

(defun common-lisp-sly/post-init-evil ()
  (defadvice sly-last-expression (around evil activate)
    "In normal-state or motion-state, last sexp ends at point."
    (if (and (not evil-move-beyond-eol)
             (or (evil-normal-state-p) (evil-motion-state-p)))
        (save-excursion
          (unless (or (eobp) (eolp)) (forward-char))
          ad-do-it)
      ad-do-it)))

(defun common-lisp-sly/pre-init-evil-cleverparens ()
  (spacemacs|use-package-add-hook evil-cleverparens
    :pre-init
    (progn
      (add-to-list 'evil-lisp-safe-structural-editing-modes 'lisp-mode)
      (add-to-list 'evil-lisp-safe-structural-editing-modes 'common-lisp-mode))))
    ;; :post-init
    ;; (spacemacs/toggle-evil-safe-lisp-structural-editing-on-register-hooks)))
    ;; :post-config
    ;; (setq evil-move-beyond-eol t
    ;;       evil-cleverparens-use-additional-movement-keys nil
    ;;       evil-cleverparens-use-additional-bindings nil)))

(defun common-lisp-sly/post-init-helm ()
  (spacemacs/set-leader-keys-for-major-mode 'lisp-mode
      "sI" 'spacemacs/helm-sly))

(defun common-lisp-sly/post-init-parinfer ()
  (add-hook 'lisp-mode-hook 'parinfer-mode))

(defun common-lisp-sly/post-init-rainbow-identifiers ()
  (add-hook 'lisp-mode-hook #'colors//rainbow-identifiers-ignore-keywords))

(defun common-lisp-sly/pre-init-evil ()
  (with-eval-after-load 'evil
    (when (configuration-layer/package-used-p 'sly)
      (evil-set-initial-state 'sly-mrepl-mode 'insert)
      (evil-set-initial-state 'sly-inspector-mode 'emacs)
      (evil-set-initial-state 'sly-db-mode 'emacs)
      (evil-set-initial-state 'sly-xref-mode 'emacs)
      (evil-set-initial-state 'sly-stickers--replay-mode 'emacs))))

(defun common-lisp-sly/pre-init-smartparens ()
  (with-eval-after-load 'smartparens
    (when (configuration-layer/package-used-p 'sly)
      (sp-local-pair '(sly-mrepl-mode) "'" "'" :actions nil)
      (sp-local-pair '(sly-mrepl-mode) "`" "`" :actions nil))))

(defun common-lisp-sly/pre-init-xterm-color ()
  (when (configuration-layer/package-usedp 'sly)
    (add-hook 'sly-mrepl-mode-hook (lambda () (setq xterm-color-preserve-properties t)))))


(defun common-lisp-sly/init-sly ()
  (use-package sly
    :defer t
    :init
    (spacemacs/register-repl 'sly 'sly)
    ;; note: many of these should automatically be registered by autoloads?
    ;; or does usiing use-package prevent that?
    (setq sly-contribs '(sly-asdf
                         sly-fancy
                         sly-indentation
                         sly-macrostep
                         sly-quicklisp
                         sly-repl-ansi-color
                         ;; sly-sbcl-exts  ; (doesn't exist) sly-visit-sbcl-bug
                         sly-scratch))
    (setq sly-autodoc-use-multiline t
          sly-complete-symbol*-fancy t
          sly-kill-without-query-p t
          sly-repl-history-remove-duplicates t
          sly-repl-history-trim-whitespaces t
          ;; sly-complete-symbol-function 'sly-fuzzy-complete-symbol
          sly-net-coding-system 'utf-8-unix)
    (defun sly/disable-smartparens ()
      (smartparens-strict-mode -1)
      (turn-off-smartparens-mode))
    (add-hook 'sly-repl-mode-hook #'sly/disable-smartparens)
    (spacemacs/add-to-hooks 'sly-mode '(lisp-mode-hook))
    :config
    (sly-setup)
    (spacemacs/set-leader-keys-for-major-mode 'lisp-mode
      "'" 'sly

      "cc" 'sly-compile-file
      "cC" 'sly-compile-and-load-file
      "cl" 'sly-load-file
      "cf" 'sly-compile-defun
      "cr" 'sly-compile-region
      "cn" 'sly-remove-notes

      "eb" 'sly-eval-buffer
      "ef" 'sly-eval-defun
      "eF" 'sly-undefine-function
      "ee" 'sly-eval-last-expression
      "eE" 'sly-eval-print-last-expression
      "el" 'spacemacs/sly-eval-sexp-end-of-line
      "er" 'sly-eval-region

      ;; "g" 'spacemacs/common-lisp-navigation-transient-state/body

      "gb" 'sly-pop-find-definition-stack
      "gn" 'sly-next-note
      "gN" 'sly-previous-note
      "gs" 'sly-stickers-next-sticker
      "gS" 'sly-stickers-prev-sticker

      "ha" 'sly-apropos
      "hA" 'sly-apropos-all
      "hb" 'sly-who-binds
      "hd" 'sly-disassemble-symbol
      "hh" 'sly-describe-symbol
      "hH" 'sly-hyperspec-lookup
      "hi" 'sly-inspect-definition
      "hm" 'sly-who-macroexpands
      "hp" 'sly-apropos-package
      "hr" 'sly-who-references
      "hs" 'sly-who-specializes
      "hS" 'sly-who-sets
      "ht" 'sly-toggle-trace-fdefinition
      "hT" 'sly-untrace-all
      "h<" 'sly-who-calls
      "h>" 'sly-calls-who

      "ma" 'sly-macroexpand-all
      "mo" 'sly-macroexpand-1

      "se" 'sly-eval-last-expression-in-repl
      "si" 'sly
      "sq" 'sly-quit-lisp
      "sc" 'sly-mrepl-clear-repl
      "sr" 'sly-restart-inferior-lisp
      "ss" 'sly-mrepl-sync

      "Sb" 'sly-stickers-toggle-break-on-stickers
      "Sc" 'sly-stickers-clear-defun-stickers
      "SC" 'sly-stickers-clear-buffer-stickers
      "Sf" 'sly-stickers-fetch
      "Sr" 'sly-stickers-replay
      "Ss" 'sly-stickers-dwim

      "tf" 'sly-toggle-fancy-trace
      ;; "tt" 'sly-toggle-trace-fdefinition
      ;; "tT" 'sly-toggle-fancy-trace
      ;; "tu" 'sly-untrace-all

      ;; Add key bindings for custom eval functions
      "ec" 'spacemacs/cl-eval-current-form-sp
      "eC" 'spacemacs/cl-eval-current-form
      "es" 'spacemacs/cl-eval-current-symbol-sp
      )
    (mapc (lambda (x)
            (spacemacs/declare-prefix-for-mode 'lisp-mode (car x) (cdr x)))
          '(("mh" . "help")
            ("me" . "eval")
            ("ms" . "repl")
            ("mc" . "compile")
            ("mg" . "nav")
            ("mm" . "macro")
            ("mt" . "toggle")
            ("mS" . "stickers")))
    ;; wrap in check of spacemacs editing mode (vim/emacs)?
    (advice-add #'sly-popup-buffer-mode :after
                (lambda (&rest _) (evil-motion-state)))
    ))

(defun common-lisp-sly/init-sly-mrepl ()
  (use-package sly-mrepl
    :after sly
    :bind
    (:map sly-mrepl-mode-map
          ("<up>" . sly-mrepl-previous-input-or-button)
          ("<down>" . sly-mrepl-next-input-or-button)
          ("<C-up>" . sly-mrepl-previous-input-or-button)
          ("<C-down>" . sly-mrepl-next-input-or-button))))

(defun common-lisp-sly/post-init-company ()
  (spacemacs|add-company-backends
    :backends company-capf
    :modes sly-mode sly-mrepl-mode))

(defun common-lisp-sly/init-sly-macrostep ()
  (use-package sly-macrostep
    :after sly
    :config
    (when (configuration-layer/layer-usedp 'emacs-lisp)
      (spacemacs/set-leader-keys-for-major-mode 'lisp-mode
        "ms" 'spacemacs/macrostep-transient-state/body))))

(defun common-lisp-sly/init-sly-repl-ansi-color ()
  (use-package sly-repl-ansi-color
    ;; :demand t
    ;; :config (push 'sly-repl-ansi-color sly-contribs)
    ))

(defun common-lisp-sly/init-sly-quicklisp ()
  (use-package sly-quicklisp
    ;; :demand t                         ; XXX necessary?
    ;; :config (push 'sly-quicklisp sly-contribs)
    ))

(defun common-lisp-sly/init-sly-asdf ()
  (use-package sly-asdf
    ;; :demand t                         ; XXX necessary?
    ;; :config (push 'sly-asdf sly-contribs)
    ))
