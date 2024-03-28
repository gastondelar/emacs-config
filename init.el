(add-to-list 'load-path "~/.emacs.d/better-defaults")

(require 'better-defaults)
(package-initialize)
(setq package-archives '(("gnu" . "https://elpa.gnu.org/packages/")
                         ("melpa" . "https://melpa.org/packages/")))


(setq create-lockfiles nil)
(
  defvar prelude-packages
  '(
    use-package
    magit
    flycheck
    company
    tide
    ess
    default-text-scale
    magit
  )
  "paquetes que deben estar instalados al iniciar"
)

(defun prelude-packages-installed-p (packages)
  "checkea que la lista de paquetes parámetro esté instalada"
  (cl-loop for p in packages
        when (not (package-installed-p p)) do (cl-return nil)
        finally (cl-return t)))



(unless (prelude-packages-installed-p prelude-packages)
  ;;checkeo packages nuevos
  (message "%s" "Emacs Prelude is now refreshing its package database...")
  (package-refresh-contents)
  (message "%s" "done.")
  ;;install the missing packages
  (dolist (p prelude-packages)
    (when (not (package-installed-p p))
      (package-install p))))

(provide 'prelude-packages)

(defvar automodes
  '(
    ("\\.css\\'" . css-ts-mode)
    ("\\Dockerfile\\'" . dockerfile-ts-mode )
    ("\\.hs\\'" . haskell-ts-mode)
    ("\\.php\\'" . php-mode)
    ("\\.js\\'" . js-ts-mode)
    ("\\.cjs\\'" . js-ts-mode)
    ("\\.json\\'" . json-ts-mode)
    ("\\.ts\\'" . typescript-ts-mode)
    ("\\.tsx\\'" . tsx-ts-mode)
    ("\\.jsx\\'" . tsx-ts-mode)
    ("\\.rsx\\'" . tsx-ts-mode) ;; <- retool
    ("\\.jade\\'" . pug-mode)
    ("\\.pug\\'" . pug-mode)
    ("\\.html\\'" . html-mode )
    ("\\.handlebars\\'" . html-mode)
    ("\\.hbs\\'" . html-mode)
    ("\\.r\\'" . ess-r-mode)
    ("\\.R\\'" . ess-r-mode)
    ("\\.yaml\\'" . yaml-ts-mode)
    ("\\.yml\\'" . yaml-ts-mode))
    ()
    ("asociaciones de nombres de archivo con modos")
    )

  (dolist (am automodes)
    (add-to-list 'auto-mode-alist am))

(defvar keybinds
  '(("M-<up>" . scroll-down-line)
    ("M-<down>" . scroll-up-line)
;;    ("C-<mouse-4>" . text-scale-increase)
;;    ("C-<mouse-5>" . text-scale-decrease)
)
   "key binding pairs" )

;;bindeo teclas a funciones
 (dolist (kf keybinds)
   (global-set-key (kbd (car kf)) (cdr kf)))



;;  layout / utility:

;; completion UI

;; ;; minibuffer:
(use-package vertico
  :ensure t
  :bind(:map vertico-map
             ("TAB" . #'minibuffer-complete)
             )
  :init
  (vertico-mode))
(use-package vertico-directory
  :after vertico
  :ensure nil)

;;config mostly from vertico github
(use-package savehist
  :ensure t
  :init (savehist-mode))

;; Enable rich annotations using the Marginalia package
(use-package marginalia
  :ensure t
  ;; Bind `marginalia-cycle' locally in the minibuffer.  To make the binding
  ;; available in the *Completions* buffer, add it to the
  ;; `completion-list-mode-map'.
  :bind (:map minibuffer-local-map
         ("M-A" . marginalia-cycle))
  ;; The :init section is always executed.
  :init
  (marginalia-mode))



(use-package emacs
  :init
  ;; Do not allow the cursor in the minibuffer prompt
  (setq minibuffer-prompt-properties
        '(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)
  
  ;; Support opening new minibuffers from inside existing minibuffers.
  (setq enable-recursive-minibuffers t)
  
  ;; Emacs 28 and newer: Hide commands in M-x which do not work in the current
  ;; mode.  Vertico commands are hidden in normal buffers. This setting is
  ;; useful beyond Vertico.
  (setq read-extended-command-predicate #'command-completion-default-include-p))

;; ;; in buffer completion
(use-package corfu
  :ensure t
  :custom
  (corfu-cycle t)
  (corfu-auto t)
  (corfu-autoprefix 1)
  (corfu-auto-delay 0.5)
  (corfu-quit-at-boundary 'separator) ;; try with orderless 
  (corfu-echo-documentation 0.25)
  (corfu-preselect-first nil)
  :bind (:map corfu-map
              ("RET" . nil)
              ("M-SPC" . corfu-insert-separator) ;; try with orderless
              )
  :init
  (global-corfu-mode)
  (corfu-history-mode)
  (corfu-popupinfo-mode)
  :config
  (setq corfu-popupinfo-delay 0.0)
  )

;; Example configuration for Consult
(use-package consult
  :ensure t
  ;; Replace bindings. Lazily loaded due by `use-package'.
  :bind (;; C-c bindings in `mode-specific-map'
         ;; ("C-c M-x" . consult-mode-command)
         ;; ("C-c h" . consult-history)
         ;; ("C-c k" . consult-kmacro)
         ;; ("C-c m" . consult-man)
         ;; ("C-c i" . consult-info)
         ;; ([remap Info-search] . consult-info)
                ;; C-x bindings in `ctl-x-map'
         ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
         ("C-x b" . consult-buffer)                ;; orig. switch-to-buffer
         ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
         ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
         ("C-x t b" . consult-buffer-other-tab)    ;; orig. switch-to-buffer-other-tab
         ("C-x r b" . consult-bookmark)            ;; orig. bookmark-jump
         ("C-x p b" . consult-project-buffer)      ;; orig. project-switch-to-buffer
         ;; Other custom bindings
         ("M-y" . consult-yank-pop)                ;; orig. yank-pop
         ("M-g M-g" . consult-goto-line)
         ;; ("C-M-y" . consult-yank-from-kill-ring) ;; aggregado luego sacado porque es lo mismo que m y sin haber yankeado antes
              ;; M-s bindings in `search-map'
         ;; ("M-s d" . consult-find)                  ;; Alternative: consult-fd
         ;; ("M-s c" . consult-locate)
         ("M-s g" . consult-grep)
         ;; ("M-s G" . consult-git-grep)
         ;; ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ;; ("M-s k" . consult-keep-lines)
         ;; ("M-s u" . consult-focus-lines)
         ;; Minibuffer history
         ;; :map minibuffer-local-map
         ;; ("M-s" . consult-history)                 ;; orig. next-matching-history-element
         ;; ("M-r" . consult-history))
         )
  :init 
  ;; Optionally configure preview. The default value
  ;; is 'any, such that any key triggers the preview.
  ;; (setq consult-preview-key 'any)
  ;; (setq consult-preview-key "M-.")
  ;; (setq consult-preview-key '("S-<down>" "S-<up>"))
  ;; For some commands and buffer sources it is useful to configure the
  ;; :preview-key on a per-command basis using the `consult-customize' macro.
  ;; (consult-customize
  ;;  consult-theme :preview-key '(:debounce 0.2 any)
  ;;  consult-ripgrep consult-git-grep consult-grep
  ;;  consult-bookmark consult-recent-file consult-xref
  ;;  consult--source-bookmark consult--source-file-register
  ;;  consult--source-recent-file consult--source-project-recent-file
  ;;  ;; :preview-key "M-."
  ;;  :preview-key '(:debounce 0.4 any))
  ;; Optionally configure the narrowing key.
  ;; Both < and C-+ work reasonably well.
  (setq consult-narrow-key "<")
  )

;; run file at point with jest
(defun embark-custom-test-file (file)
  (let ((default-directory tide-project-root))
    (message (shell-command-to-string (format "npx jest %s" file)))
   )
  )

;; @TODO run current buffer with jest

(use-package embark
  :ensure t
  :bind
  (("C-." . embark-act)         ;; pick some comfortable binding
   ("C-;" . embark-dwim)        ;; good alternative: M-.
   ("C-h B" . embark-bindings)) ;; alternative for `describe-bindings'
  :init
  ;; Optionally replace the key help with a completing-read interface
  (setq prefix-help-command #'embark-prefix-help-command)

  ;; Show the Embark target at point via Eldoc. You may adjust the
  ;; Eldoc strategy, if you want to see the documentation from
  ;; multiple providers. Beware that using this can be a little
  ;; jarring since the message shown in the minibuffer can be more
  ;; than one line, causing the modeline to move up and down:
  ;; (add-hook 'eldoc-documentation-functions #'embark-eldoc-first-target)
  ;; (setq eldoc-documentation-strategy #'eldoc-documentation-compose-eagerly)

  :config
  (keymap-set embark-file-map "T" #'embark-custom-test-file)
  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

;; Consult users will also want the embark-consult package.
(use-package embark-consult
  :ensure t ; only need to install it, embark loads it after consult if found
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

(use-package expand-region
  :ensure t
  :bind (("C-=" . er/expand-region)
         ("C--" . er/contract-region)))

(use-package exec-path-from-shell
  :ensure t
  :config (when (memq window-system '(mac ns x))
            (exec-path-from-shell-initialize)))
 
(use-package default-text-scale
  :ensure t)

(use-package rainbow-delimiters
  :ensure t)

(use-package doom-themes
  :ensure t
  :config
    ;; Global settings (defaults)
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
        doom-themes-enable-italic t) ; if nil, italics is universally disabled
  (load-theme 'doom-city-lights t) ; capaz la t no va
  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

(use-package all-the-icons
  :ensure t)

;; unsure of why i installed this 
;; (use-package solaire-mode
;;   :ensure t)


;; development:

(use-package magit
  :ensure t
  :config (setq magit-view-git-manual-method 'man) )

(setq web-mode-markup-indent-offset 2)
(setq web-mode-code-indent-offset 2)
(setq web-mode-css-indent-offset 2)
(use-package web-mode
  :ensure t
  :mode (("\\.html\\'" . web-mode))
  :commands web-mode)

(setq js-indent-level 2)
; '(js-indent-level 2)
; '(js2-basic-offset 2)
(use-package rjsx-mode
  :ensure t
  :mode (("\\.js\\'" . rjsx-mode)
         ("\\.jsx\\'" . rjsx-mode)))

(use-package xref-js2
  :after js-mode2
  :init (define-key js-mode-map (kbd "M-.") nil)
  :config (xref-js2-xref-backend nil t) )

(use-package tern-mode
  :hook js-mode2
  :config ((define-key tern-mode-keymap (kbd "M-.") nil)
           (define-key tern-mode-keymap (kbd "M-,") nil)))

;;(setq company-minimum-prefix-length 1
;;      company-idle-delay 0.4)
(use-package company-mode
 :ensure company
  :defer t
  :config ((setq company-tooltip-align-annotations t)
           (define-key c++-mode-map [(tab)] 'company-complete)
           (dabbrev-upcase-means-case-fold-search t)
           )
  :init (add-hook 'after-init-hook 'global-company-mode)
  :config (add-to-list 'company-backends _BACKEND_HERE)
   :hook (php-mode)
)

(use-package flycheck
  :ensure t
  :defer t
  ;;  :hook (php-mode)
  ;;  :init (global-flycheck-mode)
)

(use-package modern-cpp-font-lock
  :ensure t)

(use-package tide
  :ensure t
  :hook
  (typescript-ts-mode . tide-setup)
  (typescript-ts-mode . tide-hl-identifier-mode)
;;  (typescript-mode . flycheck-mode)
;;  (typescript-mode . company-mode)
  :config
  (setq tide-always-show-documentation t)
;;)
  (setq tide-completion-show-source t)
  (setq tide-completion-detailed t)
  (setq tide-server-max-response-length 120000)
  ) ;;por algun motivo no corre si pongo todo en config 

(use-package company-php
  :ensure t)
(use-package ac-php
  :ensure t
  :hook (php-mode . (lambda ()
             ;; Enable company-mode
             (company-mode t)
             (require 'company-php)
             ;; Enable ElDoc support (optional)
             (ac-php-core-eldoc-setup)

             (set (make-local-variable 'company-backends)
                  '((company-ac-php-backend company-dabbrev-code)
                    company-capf company-files))

             ;; Jump to definition (optional)
             (define-key php-mode-map (kbd "M-.")
               'ac-php-find-symbol-at-point)
             
             ;; Return back (optional)
             (define-key php-mode-map (kbd "M-,")
               'ac-php-location-stack-back)
             ))
)

(use-package request
  :ensure t)

;; lenguages estadisticos, para R
(use-package ess
  :ensure t)

;; * falopa:
;; musica
(use-package tidal
  :ensure t)


(setq tide-format-options '(:insertSpaceAfterFunctionKeywordForAnonymousFunctions t :placeOpenBraceOnNewLineForFunctions nil :indentSize 2 :tabSize 2))
(require 'project)
(setq sgml-basic-offset 2) 
;;(solaire-global-mode +1)
(delete-selection-mode 1)
(desktop-save-mode 1)
(column-number-mode)
(yas-global-mode 1)
(rainbow-delimiters-mode)
(recentf-mode)
(default-text-scale-mode)
(default-text-scale-increase)
(default-text-scale-increase)
(default-text-scale-increase)
(default-text-scale-increase)
;;(default-text-scale-increase)

;; home made functions

(defun curl-current-file ()
  "uses current buffer file as config for a curl request"
  (interactive)
  (shell-command
   (mapconcat 'identity ("curl" (concat "-K" buffer-file-name "--no-progress-meter")) " ")
   )
  )
(global-set-key (kbd "C-c C-c") 'curl-current-file)

(defun eldoc-buffer-on-side-window ()
  "eldoc on side window"
  (interactive)
  (let (
        (currentWindow (selected-window))
        (newWindow (split-window-right -50))
        (docBuf (eldoc-doc-buffer))
        )
    (set-window-parameter newWindow 'window-size-fixed 'width)
    (select-window newWindow)
    (switch-to-buffer docBuf nil t)
    (select-window currentWindow)
    )
  )

(global-set-key (kbd "C-M-!") 'eldoc-buffer-on-side-window)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("d1cc05d755d5a21a31bced25bed40f85d8677e69c73ca365628ce8024827c9e3" default)))
 '(haskell-mode-hook (quote (turn-on-haskell-indentation)))

 '(package-selected-packages
   (quote
    (tide-mode tide ag js2-refactor xref-js2 use-package php-mode magit js2-mode haskell-mode expand-region  ack-and-a-half))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; agda mode
;; (load-file (let ((coding-system-for-read 'utf-8))
;;                (shell-command-to-string "agda-mode locate")))
;;(require 'sclang)

(setq read-file-name-completion-ignore-case nil)
(setq mac-command-modifier 'meta)
(setq mac-option-modifier nil)
(setq eldoc-echo-area-use-multiline-p t)
(setq eldoc-echo-area-prefer-doc-buffer t)
(setq tide-server-max-response-length 200000)
(setq tab-always-indent 'complete)
(setq bookmark-use-annotations t)

(setq treesit-language-source-alist
   '((bash "https://github.com/tree-sitter/tree-sitter-bash")
     (cmake "https://github.com/uyha/tree-sitter-cmake")
     (css "https://github.com/tree-sitter/tree-sitter-css")
     (elisp "https://github.com/Wilfred/tree-sitter-elisp")
     (go "https://github.com/tree-sitter/tree-sitter-go")
     (html "https://github.com/tree-sitter/tree-sitter-html")
     (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "master" "src")
     (json "https://github.com/tree-sitter/tree-sitter-json")
     (make "https://github.com/alemuller/tree-sitter-make")
     (markdown "https://github.com/ikatyang/tree-sitter-markdown")
     (python "https://github.com/tree-sitter/tree-sitter-python")
     (toml "https://github.com/tree-sitter/tree-sitter-toml")
     (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
     (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
     (yaml "https://github.com/ikatyang/tree-sitter-yaml")
     (haskell "https://github.com/tree-sitter/tree-sitter-haskell")
     (php "https://github.com/tree-sitter/tree-sitter-php") ;; not working
     (r "https://github.com/r-lib/tree-sitter-r")
     ))

