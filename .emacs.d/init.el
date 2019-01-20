;;; A great operating system, lacking a decent editor
;;; Never uses emacs other than for customizing it
;;; Namespace your function with `fu`

;;; First aid kit:
;;;   + C-h v (describe-variable)
;;;   + C-h k (describe-keybinding)

;;; Emacsen's config
;;;   + https://github.com/rememberYou/.emacs.d/blob/master/config.org
;;;   + https://github.com/aaronbieber/dotfiles

;;; Need more research:
;;;   + http://emacs-fu.blogspot.com/2011/02/keeping-your-secrets-secret.html

;; Make Startup faster by reducing the frequency of garbage collection
(setq gc-cons-threshold (* 50 1000 1000))

;; Host-based global variables
(cond
 ((string-equal system-name "DLWLRMA")
  (progn
    (setq fu-font-size 140)))
 ((string-equal system-name "iudiary")
  (progn
    (setq fu-font-size 120))))

;; Package and it's manager
(require 'package)
(setq-default load-prefer-newer t package-enable-at-startup nil)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)
(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/") t)
(package-initialize)

;; Check if use-package is available, if not install it
(unless (and (package-installed-p 'use-package))
  (package-refresh-contents)
  (package-install 'use-package t))

;; Make GC pauses faster by decreasing the threshold
(setq gc-cons-threshold (* 2 1000 1000))

;; Better default
(setq
 user-full-name "adakbar"
 user-mail-address "adamakbar1729@gmail.com"
 scroll-conservatively most-positive-fixnum  ;; Scroll modernly
 tab-width 4)
(cd "~/")
(fset 'yes-or-no-p 'y-or-n-p)
(global-hl-line-mode)
(setq-default indent-tabs-mode nil)
(prefer-coding-system 'utf-8)

(use-package no-littering
  :ensure t
  :config
  ;; The holy grail of emacs temp file, at last!
  (setq auto-save-file-name-transforms
    `((".*" ,(no-littering-expand-var-file-name "auto-save/") t)))

  ;; Purify my beautiful init.el from polluted auto generated custom
  (setq custom-file (expand-file-name "custom.el" user-emacs-directory)))

(use-package markdown-mode
  :ensure t
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
     ("\\.md\\'" . markdown-mode)
     ("\\.markdown\\'" . markdown-mode))
  :init (setq markdown-command "pandoc"))

;; such EVIL
(use-package evil
  :ensure t
  :init
  (setq evil-want-keybinding nil)

  (use-package evil-leader
    :ensure t
    :config
    (global-evil-leader-mode)
    (evil-leader/set-leader "<SPC>"))

  (use-package evil-escape
    :ensure t
    :config
    (setq-default evil-escape-key-sequence "kj")
    (setq-default evil-escape-delay 0.1)
    (evil-escape-mode t))

  (fset 'evil-visual-update-x-selection 'ignore)
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :ensure t
  :config
  (evil-collection-init))

(use-package evil-mc
  :after evil
  :ensure t
  :config
  (global-evil-mc-mode 1))

(use-package helm
  :ensure t
  :config
  (helm-mode 1)
  (global-set-key (kbd "M-x") 'helm-M-x)
  (global-set-key (kbd "C-x C-f") 'helm-find-files))

;; Projectile, project management
(use-package projectile
  :ensure t
  :init
  ;; make `.projectile` to be exclusive project marker and the default is secondary
  ;; refs: https://www.reddit.com/r/emacs/comments/920psp/projectile_ignoring_projectile_files/e32u6tk
  (setq projectile-project-root-files #'( ".projectile" ))
  (setq projectile-project-root-files-functions #'(projectile-root-top-down
                                             projectile-root-top-down-recurring
                                             projectile-root-bottom-up
                                             projectile-root-local))
  :config
  (projectile-global-mode)

  (setq projectile-enable-caching t)

  (use-package helm-projectile
    :ensure t
    :config
    (setq projectile-completion-system 'helm)
    (helm-projectile-on))
  )

(use-package powershell
  :ensure t)

(use-package vue-mode
  :ensure t)

;; PHP Lang
(use-package php-mode
  :ensure t
  :config
  (defun fu/php-mode-hook ()
    (setq indent-tabs-mode nil)

    ;; Commenting is broken, solution below doesn't really
    ;; solve it, but it will do
    ;; and I guess this has something to do with the global
    ;; comment mode
    ;; [0] https://stackoverflow.com/questions/10758743/how-to-configure-emacs-to-properly-comment-code-in-php-mode
    (setq
     comment-multi-line nil
     comment-start "// "
     comment-end ""
     comment-style 'indent
     comment-use-syntax t))

  ;; [0] http://www.blogbyben.com/2016/08/emacs-php-modern-and-far-more-complete.html
  (defun fu/toggle-php-web-mode ()
    (interactive)
    "Toggle mode between PHP & Web-Mode"
    (cond ((string= mode-name "PHP//l")
           (web-mode))
          ((string= mode-name "Web")
           (php-mode))))

  (add-hook 'php-mode-hook 'php-enable-symfony2-coding-style 'fu/php-mode-hook))

(use-package web-mode
  :ensure t
  :config

  ;; set web-mode as default mode for this file
  (add-to-list 'auto-mode-alist '("\\.phtml\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.tpl\\.php\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.blade\\.php\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.[agj]sp\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.as[cp]x\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.mustache\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.djhtml\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))

  ;; change comment style to "//"
  (add-to-list 'web-mode-comment-formats '("jsx" . "//" ))
  (add-to-list 'web-mode-comment-formats '("javascript" . "//" ))

  (setq web-mode-tag-auto-close-style t)
  (setq web-mode-enable-auto-closing t)
  (setq web-mode-enable-auto-pairing t)
  (setq web-mode-enable-auto-indentation t)
  (setq web-mode-enable-auto-opening t)
  (setq web-mode-enable-auto-quoting nil)

  ;; indent to two
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-css-indent-offset 2)
  (setq web-mode-code-indent-offset 4)

  ;; Highlight current element and current column
  (setq web-mode-enable-current-element-highlight t)
  (setq web-mode-enable-current-column-highlight t)

  ;; JSX inside .js file, if JSX not correctly color-coded re-enter web-mode manually
  (setq web-mode-content-types-alist '(("jsx" . "\\.js[x]?\\'"))))

;; Auto complete with the right company
;; [0] https://www.monolune.com/configuring-company-mode-in-emacs
;; [1] https://www.reddit.com/r/emacs/comments/8z4jcs/tip_how_to_integrate_company_as_completion
(use-package company
  :ensure t
  :defer 2
  :diminish
  :custom
  (company-begin-commands '(self-insert-command))
  (company-idle-delay 0)
  (company-minimum-prefix-length 2)
  (company-show-numbers t)
  (company-tooltip-align-annotations 't)
  (global-company-mode t))

(use-package ac-php
  :after company
  :ensure t)

(use-package company-php
  :ensure t
  :after company
  :config
  (add-hook 'php-mode-hook
            '(lambda ()
               (require 'company-php)
               (company-mode t)
               (ac-php-core-eldoc-setup)
               (make-local-variable 'company-backends)
               (add-to-list 'company-backends 'company-ac-php-backend))))

(use-package smartparens
  :ensure t
  :config
  (progn
    (show-smartparens-global-mode t)))

(add-hook 'emacs-lisp-mode-hook #'turn-on-smartparens-strict-mode)

;; [0] https://emacs.stackexchange.com/questions/14282/replace-splash-screen-with-list-of-recentf
(use-package dashboard
  :preface
  (defun fu/dashboard-banner ()
    "Set a dashboard banner including information on package init
time and garbage collections."
    (setq dashboard-banner-logo-title
          (format "Mothership ready in %.2f seconds with %d garbage collections."
                  (float-time (time-subtract after-init-time before-init-time)) gcs-done)))
  :init
  (add-hook 'after-init-hook 'dashboard-refresh-buffer)
  (add-hook 'dashboard-mode-hook 'fu/dashboard-banner)
  :ensure t
  :diminish dashboard-mode
  :custom (dashboard-startup-banner 'logo)
  :config

  (setq dashboard-items '((recents . 5)
                          (bookmarks . 5)
                          (projects . 5)))
  (dashboard-setup-startup-hook))

;; doc-view mode
(setq doc-view-resolution 300)
(setq doc-view-continuous t)

;; neotree
;; [0] https://www.emacswiki.org/emacs/NeoTree
(use-package neotree
  :ensure t
  :config
  (setq neo-theme (if (display-graphic-p) 'icons 'arrow))

  ;; When neotree open if follow to current file's node
  (setq neo-smart-open t)

  ;; When change project neotree will also change its current dir
  (setq projectile-switch-project-action 'neotree-projectile-action))

;; Not sure how this will work in Windows
;; [0] https://emacs.stackexchange.com/questions/10722/emacs-and-command-line-path-disagreements-on-osx
(use-package exec-path-from-shell
  :ensure t)

(defun fu/edit-init ()
  "Edit the `user-init-file', in another window."
  (interactive)
  (find-file-other-window user-init-file))

;; org-mode
(use-package org
  :mode (("\\.org$" . org-mode))
  :ensure org-plus-contrib ;; contrib goodies!
  :config
  (progn
    ))

;; fu function
(defun fu/window-toggle-fullscreen ()
  "Toggle active window to fullscreen
it doing so by save the window configuration to 'winsavestack
so at later can be restored, also hide neotree
[0] http://ergoemacs.org/emacs/emacs_winner_mode.html"
  (interactive)
  (cond((eq (one-window-p) nil)
         (window-configuration-to-register 'winsavestack)
         (neotree-hide)
         (delete-other-windows))
        ((eq (one-window-p) t)
         (jump-to-register 'winsavestack t))))

(defun fu/revert-buffer-no-confirm ()
  "Revert buffer without confirmation."
  (interactive)
  (revert-buffer :ignore-auto :noconfirm))

(defun fu/wsl-shell ()
  (let ((explicit-shell-file-name "C:/Windows/System32/bash.exe"))
    (shell)))

;; Spellbind
(define-key evil-motion-state-map "j" 'evil-next-visual-line)
(define-key evil-motion-state-map "k" 'evil-previous-visual-line)
(global-set-key (kbd "C-M-j") 'evil-mc-make-cursor-move-next-line)
(global-set-key (kbd "C-M-k") 'evil-mc-make-cursor-move-prev-line)

;; Use M-RET to actually complete the selection
;; [0] https://emacs.stackexchange.com/questions/13286/how-can-i-stop-the-enter-key-from-triggering-a-completion-in-company-mode
(with-eval-after-load 'company
  (define-key company-active-map (kbd "<return>") nil)
  (define-key company-active-map (kbd "RET") nil)
  (define-key company-active-map (kbd "M-<return>") #'company-complete-selection))

(evil-leader/set-key
  ;; Window ops
  "wsr" 'split-window-right
  "wsb" 'split-window-below
  "wf" 'fu/window-toggle-fullscreen
  "wh" 'evil-window-left
  "wj" 'evil-window-down
  "wk" 'evil-window-up
  "wl" 'evil-window-right
  "wd" 'evil-window-delete
  "wt" 'neotree-toggle

  ;; Buffers
  "bl" 'helm-buffers-list
  "bk" 'kill-this-buffer
  "br" 'fu/revert-buffer-no-confirm

  ;; Org mode
  "ot" 'org-todo
  "olc" 'org-store-link
  "olp" 'org-insert-link
  "olo" 'org-open-at-point
  "obc" 'org-cycle-list-bullet

  ;; Web mode
  "cc" 'web-mode-comment-or-uncomment

  ;; Projectile X Helm
  "pp" 'helm-projectile-switch-project
  "pf" 'helm-projectile-find-file

  ;; Helm
  "ff" 'helm-find-files

  ;; Language specific
  "lpt" 'fu/toggle-php-web-mode
  "ele" 'eval-expression

  ;; Zoom in/out
  "zz" 'text-scale-increase
  "zx" 'text-scale-decrease

  ;; Evil-mc
  "emd" 'evil-mc-undo-all-cursors
  )

;; Aftermath

;; In macOS exec system PATH
(when (memq window-system '(mac ns x))
  (exec-path-from-shell-initialize))

(setq inhibit-splash-screen t
      initial-scratch-message nil)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; Themes and color carnival
(set-face-attribute 'default nil :family "Source Code Pro" :height fu-font-size)

;; Beatiful themes
(use-package grandshell-theme
  :ensure t
  :config
  (load-theme 'grandshell t))

;; Auto-save when emacs loses focus
;;(add-hook 'focus-out-hook (lambda () (save-some-buffers t)))

;; Trim spaces and add newline while saving
;; [0] http://www.gonsie.com/notes/2017/12/09/subl-to-emacs.html
(add-hook 'before-save-hook 'delete-trailing-whitespace)
(setq require-final-newline t)

;; Move generated elisp by custom-* interface
;; [0] http://emacsblog.org/2008/12/06/quick-tip-detaching-the-custom-file/
(setq custom-file "~/.emacs.d/custom.el")
(load custom-file 'noerror)

;; The backup saga
;; ref: https://stackoverflow.com/questions/151945/how-do-i-control-how-emacs-makes-backup-files
;; note that symlink of ".#" is an interlocking mechanism for emacs to detect simultaneously editing not an auto-save or cache file
(defvar --backup-directory (concat user-emacs-directory "backups"))
(if (not (file-exists-p --backup-directory))
    (make-directory --backup-directory t))
(setq backup-directory-alist `(("." . ,--backup-directory)))
(setq make-backup-files t         ; backup of a file the first time it is saved
      backup-by-copying t         ; don't clobber symlinks
      version-control t           ; version numbers for backup files
      delete-old-versions t       ; delete those excess annoying backup
      delete-by-moving-to-trash t ; delete excess backup files silently
      kept-old-version 6          ; oldest versions to keep when a new numbered backup is made (default: 2)
      kept-new-version 9          ; newest versions to keep when a new numbered backup is made (default: 2)
      auto-save-default t         ; auto-save every buffer that visits a file
      auto-save-timeout 20        ; number of seconds idle time before auto-save (default: 30)
      auto-save-interval 200      ; number of keystrokes between auto-saves (default: 300)
      )

