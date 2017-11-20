;;; parglare-mode.el --- Major mode for editing parglare files   -*- lexical-binding: t; -*-

;; Copyright (C) 2017 parglare-mode contributors.

;; Author: Igor R. Dejanovic, igor DOT dejanovic AT gmail
;; URL: https://github.com/igordejanovic/parglare-mode
;; Keywords: parglare, parser
;; Version: 0.1
;; Package-Requires: ((emacs "24.3"))

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Basic mode for editing parglare grammars.
;; See <https://github.com/igordejanovic/parglare>

;;; Code:

(defgroup parglare nil
  "Major mode for editing parglare code."
  :prefix "parglare-"
  :group 'languages
  :link '(url-link :tag "Github" "https://github.com/igordejanovic/parglare-mode"))

(defcustom parglare-tab-width 4
  "Tab width in parglare grammars."
  :type '(integer)
  :group 'parglare)

(defconst parglare-mode-syntax-table
  (let ((table (make-syntax-table)))
    (modify-syntax-entry ?_ "w" table)
    (modify-syntax-entry ?/ "\". 124b" table)
    (modify-syntax-entry ?| ". 23" table)
    (modify-syntax-entry ?: ". 23" table)
    (modify-syntax-entry ?{ ". 23" table)
    (modify-syntax-entry ?} ". 23" table)
    (modify-syntax-entry ?= ". 23" table)
    (modify-syntax-entry ?\n "> b" table)
    (modify-syntax-entry ?' "\"" table)
    (modify-syntax-entry ?\" "\"" table)
    table)
  "Syntax table used in parglare buffers.")


(defconst parglare-keywords '("left"
                              "right"
                              "prefer"
                              "dynamic"))

(defconst parglare-interpunction '(":" "|" "{" "}" "=" "?="))


(defvar parglare-font-lock-keywords
  (list
   (cons (regexp-opt parglare-keywords 'words) font-lock-keyword-face)
   (cons (regexp-opt parglare-interpunction 'symbol) font-lock-keyword-face)
   (cons "\_<@\\(\\sw\\|\\s_\\)+\_>" font-lock-keyword-face)))

;; Comments
(set (make-local-variable 'comment-start) "// ")
(set (make-local-variable 'comment-end)   "")
(set (make-local-variable 'comment-use-syntax) t)
(set (make-local-variable 'comment-start-skip) "\\(//+\\|/\\*+\\)\\s *")

(defun parglare-indent-line ()
  "Indent current line as parglare code."
  (interactive)
  (let ((savep (> (current-column) (current-indentation)))
        (indent (condition-case nil (max (parglare-calculate-indentation) 0)
                  (error 0))))
    (if savep
        (save-excursion (indent-line-to indent))
      (indent-line-to indent))))

(defun parglare-calculate-indentation ()
  "Calculates desired indentation of a line."
(interactive)
  (save-excursion
    (beginning-of-line)
    (cond
     ((looking-at ".*;[ \t]*$") 0)
     ((looking-at "[ \t]*\|") 5)
     ((looking-at "^[ \t]*\\([A-Z][a-z0-9]+\\)+:") 10)
     ;; Everything else is indented for one tab.
     (t parglare-tab-width))))

(defvar parglare-imenu-generic-expression
  ;; Everything that match this regexp is considered as parglare term definition.
  ;; `imenu-generic-expression' works only for top level forms.
  '(("Definition" "^\\([A-Z][a-z0-9]+\\)+:$" 1))
  ;; For more versatile or structured `imenu' a parser function
  ;; `imenu-create-index-function' should be used.
  "Value for `imenu-generic-expression' in parglare mode.")

;;;###autoload
(define-derived-mode parglare-mode prog-mode "parglare"
  :syntax-table parglare-mode-syntax-table
  (setq font-lock-defaults '(parglare-font-lock-keywords))
  (setq-local comment-start "// ")
  ;; (setq-local indent-line-function 'parglare-indent-line)
  (setq-local imenu-generic-expression parglare-imenu-generic-expression))

;; Activate parglare-mode for files with .pg extension
;;;###autoload
(add-to-list 'auto-mode-alist '("\\.pg\\'" . parglare-mode))

(provide 'parglare-mode)

;;; parglare-mode.el ends here
