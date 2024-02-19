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
    magit expand-region
    haskell-mode
    php-mode
    js2-mode
    ag ;;dependencia de xref
    xref-js2
    ;;js2-refactor rever configuración y uso
    flycheck
    pug-mode
    company
    tide
    ess
    ac-php
    gruvbox-theme
    cyberpunk-theme
    default-text-scale
    neotree
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
  '( ("\\.hs\\'" . haskell-mode)
     ("\\.php\\'" . php-mode)
;;     ("\\.js\\'" . js2-mode)
     ("\\.jade\\'" . pug-mode)
     ("\\.pug\\'" . pug-mode)
     ("\\.html\\'" . web-mode)
     ("\\.handlebars\\'" . web-mode)
     ("\\.hbs\\'" . web-mode)
;;     ("\\.ts\\'" . web-mode)
;;     ("\\.tsx\\'" . web-mode)
     ("\\.r\\'" . ess-r-mode)
     ("\\.R\\'" . ess-r-mode)
  "asociaciones de nombres de archivo con modos"))

(dolist (am automodes)
          (add-to-list 'auto-mode-alist am))

(defvar keybinds
  '(("M-<up>" . scroll-down-line)
    ("M-<down>" . scroll-up-line)
    ("C-<mouse-4>" . text-scale-increase)
    ("C-<mouse-5>" . text-scale-decrease)
)
   "key binding pairs" )

;;bindeo teclas a funciones
 (dolist (kf keybinds)
   (global-set-key (kbd (car kf)) (cdr kf)))



;; layout / utility:
(use-package helm
  :ensure t
  :config (helm-mode 1))

(use-package neotree
  :ensure t
  :bind (("<f8>" . neotree-toggle)))

(use-package expand-region
  :ensure t
  :bind (("C-=" . er/expand-region)
         ("C--" . er/contract-region)))

(use-package markdown-mode
  :ensure t
  :mode ("README\\.md\\'" . gfm-mode)
  :init (setq markdown-command  '("pandoc" "--from=markdown" "--to=html5")))

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
;;  (load-theme 'doom-city-lights t) ; capaz la t no va
  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  ;; Enable custom neotree theme (all-the-icons must be installed!)
  (doom-themes-neotree-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))


(use-package all-the-icons
  :ensure t)
(use-package solaire-mode
  :ensure t)

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

(setq company-minimum-prefix-length 1
      company-idle-delay 0.4)
(use-package company-mode
  :ensure company
  :defer t
  :config ((setq company-tooltip-align-annotations t)
           (define-key c++-mode-map [(tab)] 'company-complete))
  :init (add-hook 'after-init-hook 'global-company-mode)
  ;;:config (add-to-list 'company-backends _BACKEND_HERE)
  ;;  :hook (php-mode)
)

(use-package flycheck
  :ensure t
  :defer t
  ;;  :hook (php-mode)
  ;;  :init (global-flycheck-mode)
)

(use-package modern-cpp-font-lock
  :ensure t)

(use-package yasnippet
  :ensure t)

(use-package typescript-mode
  :ensure t
  :config (setq typescript-indent-level 2)
  :mode (("\\.ts\\'" . typescript-mode)
         ("\\.tsx\\'" . typescript-mode)))

(use-package tide
  :ensure t
  :hook
  (typescript-mode . tide-setup)
  (typescript-mode . tide-hl-identifier-mode)
  (typescript-mode . flycheck-mode)
  (typescript-mode . company-mode)
;        (js2-mode . tide-setup)
;        (js2-mode . tide-hl-identifier-mode)
;        (js2-mode . flycheck-mode)
;        (js2-mode . company-mode)
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
(solaire-global-mode +1)
(delete-selection-mode 1)
(desktop-save-mode 1)
(column-number-mode)
(yas-global-mode 1)
(rainbow-delimiters-mode)
(default-text-scale-mode)
(default-text-scale-increase)
(default-text-scale-increase)
(default-text-scale-increase)
(default-text-scale-increase)
(default-text-scale-increase)


(defun curl-current-file ()
  "uses current buffer file as config for a curl request"
  (interactive)
  (shell-command
   (mapconcat 'identity ("curl" (concat "-K" buffer-file-name "--no-progress-meter")) " ")
   )
  )
(global-set-key (kbd "C-c C-c") 'curl-current-file)
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

(load-file (let ((coding-system-for-read 'utf-8))
                (shell-command-to-string "agda-mode locate")))
(require 'sclang)
