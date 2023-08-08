(add-to-list 'load-path (expand-file-name "el-get/el-get" user-emacs-directory))

(unless (require 'el-get nil 'noerror)
  (with-current-buffer
      (url-retrieve-synchronously
       "https://raw.githubusercontent.com/dimitri/el-get/master/el-get-install.el")
    (goto-char (point-max))
    (eval-print-last-sexp)))

(add-to-list 'el-get-recipe-path "~/.emacs.d/el-get-user/recipes")

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


(el-get 'sync)

;; font size 120 is too big. set it to 100
(set-face-attribute 'default nil :height 110)

(custom-set-variables
 '(auto-save-mode t)
 '(blink-cursor-mode nil)
 '(column-number-mode t)
 '(delete-selection-mode t)
 '(display-time-mode t)
 '(indent-tabs-mode nil)
 '(menu-bar-mode nil)
 '(ns-command-modifier 'super)
 '(require-final-newline t)
 '(save-place-mode t)
 '(scroll-bar-mode nil)
 '(show-paren-mode t)
 '(tool-bar-mode nil)
 '(transient-mark-mode t)
 '(visible-bell nil)
 '(global-hl-line-mode t)
 '(global-hl-line-sticky-flag t))

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

;; Loading lsp-mode 
(require 'lsp-mode)
(add-hook 'go-mode-hook #'lsp-deferred)

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

;; use M-. and M-? to use the lsp-ui-peek feature
;; remap xref-find-definitions(M-.) and xref-find-references(M-?) to lsp-ui-peek
;; NB: the debugger complained about not finding lsp-ui-mode-map, so using lsp-mode-map below
(define-key lsp-mode-map [remap xref-find-definitions] #'lsp-ui-peek-find-definitions)
(define-key lsp-mode-map [remap xref-find-references] #'lsp-ui-peek-find-references)

(desktop-save-mode)
(desktop-read)

;; load treemacs upon startup
(add-hook 'after-init-hook #'treemacs)

(set-cursor-color "White")

;; resizing windows using windsize
(global-set-key (kbd "S-C-<left>") 'windsize-left)
(global-set-key (kbd "S-C-<right>") 'windsize-right)
(global-set-key (kbd "S-C-<up>") 'windsize-up)
(global-set-key (kbd "S-C-<down>") 'windsize-down)

;; really distracting on the laptop screen. let's disable it for now
;; golden-ratio mode
;;(require 'golden-ratio)
;;(golden-ratio-mode nil)

;; code-collapsing mode and associated keybindings
(hs-minor-mode)
(global-set-key (kbd "s-]") 'hs-show-block)
(global-set-key (kbd "s-[") 'hs-hide-block)
(global-set-key (kbd "s-\\") 'hs-hide-all)
(global-set-key (kbd "s-/") 'hs-show-all)
                