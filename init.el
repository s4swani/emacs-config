(add-to-list 'load-path (expand-file-name "el-get/el-get" user-emacs-directory))

(unless (require 'el-get nil 'noerror)
  (with-current-buffer
      (url-retrieve-synchronously
       "https://raw.githubusercontent.com/dimitri/el-get/master/el-get-install.el")
    (goto-char (point-max))
    (eval-print-last-sexp)))

(add-to-list 'el-get-recipe-path "~/.emacs.d/el-get-user/recipes")

;; let emacs know where the find the c language server. 
;; on this machine it's at /usr/bin/clangd 
(executable-find "clangd")

;; this is needed because of the way emacs28.2 initialises image supprt.
;; expected to be fixed in emacs 29, but el-get is broken on emacs29
;; currently, so...
;; (see https://emacs.stackexchange.com/questions/74289/emacs-28-2-error-in-macos-ventura-image-type-invalid-image-type-svg/77169#77169)
(add-to-list 'image-types 'svg)



;; Simple package names
(el-get-bundle yasnippet)
(el-get-bundle color-moccur)
(el-get-bundle switch-window)
(el-get-bundle color-theme-zenburn)
(el-get-bundle lsp-mode)
(el-get-bundle company-mode)
(el-get-bundle go-mode)
(el-get-bundle lsp-treemacs)
(el-get-bundle windsize)
(el-get-bundle golden-ratio)
(el-get-bundle lsp-ui)
(el-get-bundle pdf-tools)
(el-get-bundle flycheck)
;; ugh! building this was painful. the transient package build was failing, so
;; I went in the recipes and commented out the transient package info build,
;; Once the transient package build completed (without docs of course), then
;; the magit build completed properly.
(el-get-bundle magit)
;;(el-get-bundle helm)
(el-get 'sync)

;; font size 120 is too big. set it to 100
(set-face-attribute 'default nil :height 110)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(auto-save-mode t)
 '(blink-cursor-mode nil)
 '(column-number-mode t)
 '(delete-selection-mode t)
 '(display-time-mode t)
 '(global-hl-line-mode t)
 '(global-hl-line-sticky-flag t)
 '(indent-tabs-mode nil)
 '(menu-bar-mode nil)
 '(ns-command-modifier 'super)
 '(package-selected-packages '(popup compat))
;; '(mode-require-final-newline nil)
 '(require-final-newline t)
 '(save-place-mode t)
 '(scroll-bar-mode nil)
 '(show-paren-mode t)
 '(tool-bar-mode nil)
 '(transient-mark-mode t)
 '(visible-bell nil))

;; theme
(add-to-list 'custom-theme-load-path "~/.emacs.d/el-get/color-theme-zenburn/")
(load-theme 'zenburn t)

;; move up and down by a few (5) lines
(global-set-key (kbd "C-n")
		(lambda () (interactive) (forward-line 5)))
(global-set-key (kbd "C-p")
		(lambda () (interactive) (forward-line -5)))

;; enable windmove to navigate between windows using Shift key
(when (fboundp 'windmove-default-keybindings)
  (windmove-default-keybindings))

;; enable italics 
(setq w32-enable-italics t) 

;; M-g = gotoline
(global-set-key "\M-g" 'goto-line)

;;set the indentation default to 4
(setq c-default-style "bsd"
      c-basic-offset 4)
(setq-default standard-indent 4)

;; set value for syntax highlighting of doxygen style comments.
(setq c-doc-comment-style '((c-mode . doxygen)))

;; check values at https://emacs-lsp.github.io/lsp-mode/page/settings/diagnostics/#lsp-diagnostics-provider for other options. "nil" means Prefer flycheck. This is because flymake was clogging up the Flymake log buffer with flymake-proc-legacy-flymake errors and slowing down the emacs startup time.
(setq lsp-diagnostics-provider nil)

;; Loading lsp-mode 
(require 'lsp-mode)
;;(add-hook 'go-mode-hook #'lsp-deferred)
;;(add-hook 'c-mode-hook #'lsp)
(add-hook 'c-mode-hook #'lsp-deferred)
(add-hook 'c-mode-hook #'yas-minor-mode)

;; company mode
(add-hook 'after-init-hook 'global-company-mode)

;; as soon as the user starts typing, offer completion options
(setq company-minimum-prefix-length 1
      company-idle-delay 0.1) ;; default is 0.2

;; Set up before-save hooks to format buffer and add/delete imports.
;; Make sure you don't have other gofmt/goimports hooks enabled.
(defun lsp-go-install-save-hooks ()

  ;; format the .go file when saving a buffer
  (add-hook 'before-save-hook #'lsp-format-buffer t t)
  
  ;; fix any imports in the .go file when saving a buffer
  (add-hook 'before-save-hook #'lsp-organize-imports t t))
(add-hook 'go-mode-hook #'lsp-go-install-save-hooks)

;; Start LSP Mode and YASnippet mode
(add-hook 'go-mode-hook #'lsp-deferred)
(add-hook 'go-mode-hook #'yas-minor-mode)

(add-hook 'prog-mode-hook #'hs-minor-mode)
;; code-collapsing mode and associated keybindings
;;(setq hs-minor-mode t)
;; shortcuts for hs-mode
(global-set-key (kbd "s-]") 'hs-show-block)
(global-set-key (kbd "s-[") 'hs-hide-block)
(global-set-key (kbd "s-\\") 'hs-hide-all)
(global-set-key (kbd "s-/") 'hs-show-all)


;; display line numbers in all windows
(setq display-line-numbers (quote relative))
(global-display-line-numbers-mode t)
;; except the treemacs window
(add-hook 'treemacs-mode-hook (lambda() (display-line-numbers-mode -1)))

;; XXX:
;; // TODO: we can use this to set the library folders so the lsp-server
;; can accurately pick the pico-sdk. Currently this defaults to /usr
;;lsp-clients-clangd-library-directories


;; use M-. and M-? to use the lsp-ui-peek feature
;; remap xref-find-definitions(M-.) and xref-find-references(M-?) to lsp-ui-peek
;; NB: the debugger complained about not finding lsp-ui-mode-map, so using lsp-mode-map below

(define-key lsp-mode-map [remap xref-find-definitions] #'lsp-ui-peek-find-definitions)
(define-key lsp-mode-map [remap xref-find-references] #'lsp-ui-peek-find-references)


;; lsp-ui-doc-mode customizations
(setq lsp-ui-doc-enable t)

;; show documentation when the cursor hovers over item
(setq lsp-ui-doc-show-with-cursor t)

;; show the documentation frame on the top right of the window
(setq lsp-ui-doc-position 'top-right-corner)

;; set documetation frame size so it doesn't cover the whole window
(setq lsp-ui-doc-max-height 15)
(setq lsp-ui-doc-max-width 100)

;; enable lsp-ui-sideline (mainly used by flycheck to display errors)
(setq lsp-ui-sideline-enable t)
(setq lsp-ui-sideline-show-diagnostics t)
(setq lsp-ui-doc-enhanced-markdown t)

;; lsp-ui-sidelines-diagnostics customisations
(setq lsp-ui-sideline-diagnostic-max-line-length 30)
(setq lsp-ui-sideline-diagnostic-max-lines 6)
(global-set-key (kbd "M-n") 'flycheck-next-error)
(global-set-key (kbd "M-p") 'flycheck-previous-error)

;; view pdf files in emacs.
;; this needs to be placed before desktop is restored below or else
;; desktop-restore complains about pdf-tools-enabled-modes
(pdf-tools-install)
(add-hook 'pdf-view-mode-hook 'pdf-view-midnight-minor-mode)

;; save the open files and frames so we can pickup from where we left
;; off when emacs is restarted
(desktop-save-mode)
(desktop-read)

;; load treemacs upon startup
(add-hook 'after-init-hook #'treemacs)
(treemacs-git-commit-diff-mode)

;; cursor is a non-blinking, white block
(set-cursor-color "tomato")
(setq-default cursor-type '(box . 10))

;; when a region is selected, highlight it with a
;; colour darker than the zenburn theme
(set-face-attribute 'region nil :background "#222")

;; resizing windows using windsize
(global-set-key (kbd "S-C-<left>") 'windsize-left)
(global-set-key (kbd "S-C-<right>") 'windsize-right)
(global-set-key (kbd "S-C-<up>") 'windsize-up)
(global-set-key (kbd "S-C-<down>") 'windsize-down)

;; stop lsp-mode from automatically adding headers
(setq lsp-clients-clangd-args
    '("--header-insertion=never"))

;;;;;;;; currently not working   ;;;;;;;;;;
(add-hook 'c-mode-hook
      (lambda ()
        (local-unset-key (kbd "C-c C-d"))))

(defun duplicate-line()
  (interactive)
  (move-beginning-of-line 1)
  (kill-line)
  (yank)
  (open-line 1)
  (next-line 1)
  (yank)
)
(global-set-key (kbd "C-d") 'duplicate-line)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; really distracting on the laptop screen. let's disable it for now
;; golden-ratio mode
;;(require 'golden-ratio) 
;;(golden-ratio-mode t)
;;(setq golden-ratio-auto-scale t)
;;(setq golden-ratio-max-width 150)
