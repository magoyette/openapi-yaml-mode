;;; openapi-yaml-mode.el --- Major mode for OpenAPI YAML files.

;; Copyright (C) 2017-2018 Marc-André Goyette
;; Author: Marc-André Goyette <goyette.marcandre@gmail.com>
;; URL: https://github.com/magoyette/openapi-yaml-mode
;; Version: 0.1.0
;; Package-Requires: ((emacs "25"))
;; Keywords: languages

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; For a full copy of the GNU General Public License
;; see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;; Code:

(require 'font-lock)
(require 'yaml-mode)

(defgroup openapi-yaml nil
  "OpenAPI YAML files."
  :group 'openapi
  :prefix "openapi-yaml-")

(defcustom openapi-yaml-predicate-regexp-match-limit 4000
  "Defines the number of characters that will be scanned at the beginning of a
buffer to find the openapi or the swagger element."
  :type 'integer
  :group 'openapi-yaml)

(defcustom openapi-yaml-use-yaml-mode-syntax-highlight nil
  "If true, openapi-yaml-mode will use the regular syntax highlight of
yaml-mode."
  :type 'boolean
  :group 'openapi-yaml)

(defconst openapi-yaml-mode--syntax-table
  (let ((table (make-syntax-table)))

    (modify-syntax-entry ?' "." table)

    (modify-syntax-entry ?\" "." table)

    (set (make-local-variable 'indent-line-function) 'yaml-indent-line)
    (set (make-local-variable 'indent-tabs-mode) nil)
    (set (make-local-variable 'fill-paragraph-function) 'yaml-fill-paragraph)

    table))

;; Source : https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md
(defconst openapi-yaml-mode--openapi-keywords
  '(;; Literals
    "true"
    "false"
    ;; Mime Types
    "application/json"
    "application/x-www-form-urlencoded"
    "application/xml"
    "multipart/form-data"
    "text/plain"
    ;; Types
    "integer"
    "number"
    "string"
    "boolean"
    ;; Formats
    "int32"
    "int64"
    "float"
    "double"
    "byte"
    "binary"
    "date"
    "date-time"
    "password"
    ;; Additional Types
    "array"
    ;; JSON Schema
    "title"
    "multipleOf"
    "maximum"
    "exclusiveMaximum"
    "minimum"
    "exclusiveMinimum"
    "maxLength"
    "minLength"
    "pattern"
    "maxItems"
    "minItems"
    "uniqueItems"
    "maxProperties"
    "minProperties"
    "required"
    "enum"
    "type"
    "allOf"
    "items"
    "properties"
    "additionalProperties"
    "description"
    "format"
    "default"
    ;; Common to many objects
    "$ref"
    "deprecated"
    "example"
    "examples"
    "externalDocs"
    "headers"
    "in"
    "name"
    "operationId"
    "parameters"
    "responses"
    "schema"
    "security"
    "tags"
    "url"
    ;; Schema fields
    "info"
    "paths"
    ;; Info object
    "title"
    "termsOfService"
    "contact"
    "license"
    "version"
    ;; Contact object
    "email"
    ;; Path Item fields
    "get"
    "put"
    "post"
    "delete"
    "options"
    "head"
    "patch"
    ;; Path Item or Operation fields
    "summary"
    ;; Parameter object
    "allowEmptyValue"
    ;; Swagger allowed values for an in field
    "query"
    "header"
    "path"
    ;; Schema object fields
    "discriminator"
    "readOnly"
    "xml"
    ;; XML object
    "namespace"
    "prefix"
    "attribute"
    "wrapped"
    ;; Security Scheme or OAuth Flow fields
    "authorizationUrl"
    "tokenUrl"
    "scopes"
    ))

;; Source : https://github.com/OAI/OpenAPI-Specification/blob/master/versions/2.0.md
(defconst openapi-yaml-mode--openapi2-keywords
  (append openapi-yaml-mode--openapi-keywords
          '(;; Additional Types
            "file"
            ;; Schema fields
            "swagger"
            "host"
            "basePath"
            "definitions"
            "parameters"
            "securityDefinitions"
            ;; Swagger allowed values for an in field
            "formData"
            "body"
            ;; Security Scheme object
            "flow"

    ;;;;; TO VERIFY
            ;; Common to many objects
            "collectionFormat"
            "consumes"
            "produces"
            "scheme"
            ;; Swagger allowed values for a schemes field
            "http"
            "https"
            "ws"
            "wss"
            ;; Swagger allowed values for an collectionFormat field
            "csv"
            "ssv"
            "tsv"
            "pipes"
            "multi"
            ;; Swagger allowed values for a type field
            "basic"
            "apiKey"
            "oauth2"
            ;; Swagger allowed values for a flow field
            "implicit"
            "password"
            "application"
            "accessCode"
            )))

;; Source : https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md
(defconst openapi-yaml-mode--openapi3-keywords
  (append openapi-yaml-mode--openapi-keywords
          '(;; JSON Schema
            "oneOf"
            "anyOf"
            "not"
            ;; Common to many objects
            "allowReserved"
            "callbacks"
            "content"
            "explode"
            "links"
            "requestBody"
            "servers"
            "style"
            ;; Schema fields
            "openapi"
            "components"
            ;; Server fields
            "variables"
            ;; Components fields
            "schemas"
            "requestBodies"
            "securitySchemes"
            ;; Path Item fields
            "trace"
            ;; Swagger allowed values for an in field
            "cookie"
            ;; Style values
            "matrix"
            "label"
            "form"
            "simple"
            "spaceDelimited"
            "pipeDelimited"
            "deepObject"
            ;; Media Type fields
            "encoding"
            ;; Encoding fields
            "contentType"
            ;; Example fields
            "value"
            "externalValue"
            ;; Link fields
            "operationRef"
            "server"
            ;; Schema object fields
            "nullable"
            "writeOnly"
            ;; Discriminator fields
            "propertyName"
            "mapping"
            ;; Security Scheme fields
            "bearerFormat"
            "flows"
            "openIdConnectUrl"
            ;; OAuth Flows fields
            "implicit"
            "password"
            "clientCredentials"
            "authorizationCode"
            ;; OAuth Flow fields
            "refreshUrl"
            )))

(defun openapi-yaml-mode--openapi2-completion-at-point ()
  "Completion function for Open API 2 files."
  (let ((bounds (bounds-of-thing-at-point 'word)))
    (when bounds
      (list (car bounds)
            (cdr bounds)
            openapi-yaml-mode--openapi2-keywords))))

(defun openapi-yaml-mode--openapi3-completion-at-point ()
  "Completion function for Open API 3 files."
  (let ((bounds (bounds-of-thing-at-point 'word)))
    (when bounds
      (list (car bounds)
            (cdr bounds)
            openapi-yaml-mode--openapi3-keywords))))

(defvar openapi-yaml-markdown-header-face 'openapi-yaml-markdown-header-face
  "Face for Markdown headers in an OpenAPI YAML file.")

(defface openapi-yaml-markdown-header-face
  '((t (:inherit font-lock-type-face :weight bold)))
  "Face for Markdown headers in an OpenAPI YAML file."
  :group 'faces)

(defvar openapi-yaml-markdown-table-bold-face 'openapi-yaml-markdown-table-bold-face
  "Face for Markdown bold text in an OpenAPI YAML file.")

(defface openapi-yaml-markdown-table-bold-face
  '((t (:inherit font-lock-comment-face :weight bold)))
  "Face for Markdown bold text in an OpenAPI YAML file."
  :group 'faces)

(defvar openapi-yaml-markdown-italic-face 'openapi-yaml-markdown-italic-face
  "Face for Markdown italic text in an OpenAPI YAML file.")

(defface openapi-yaml-markdown-italic-face
  '((t (:slant italic)))
  "Face for Markdown italic text in an OpenAPI YAML file."
  :group 'faces)

(defvar openapi-yaml-http-code-face 'openapi-yaml-http-code-face
  "Face for a HTTP code in an OpenAPI YAML file.")

(defface openapi-yaml-http-code-face
  '((t (:inherit font-lock-constant-face :weight bold)))
  "Face for a HTTP code in an OpenAPI YAML file."
  :group 'faces)

(defvar openapi-yaml-http-method-face 'openapi-yaml-http-method-face
  "Face for a HTTP method name in an OpenAPI YAML file.")

(defface openapi-yaml-http-method-face
  '((t (:inherit font-lock-constant-face :weight bold)))
  "Face for a HTTP method name in an OpenAPI YAML file."
  :group 'faces)

(defvar openapi-yaml-url-path-face 'openapi-yaml-url-path-face
  "Face for an URL path in an OpenAPI YAML file.")

(defface openapi-yaml-url-path-face
  '((t (:inherit font-lock-function-name-face :weight bold)))
  "Face for an URL path in an OpenAPI YAML file."
  :group 'faces)

(defvar openapi-yaml-path-face 'openapi-yaml-path-face
  "Face for paths and references in an OpenAPI YAML file.")

(defface openapi-yaml-path-face
  '((t (:inherit font-lock-string-face :weight bold)))
  "Face for paths and references in an OpenAPI YAML file."
  :group 'faces)

(defvar openapi-yaml-definition-type-face 'openapi-yaml-definition-type-face
  "Face for a definition type in an OpenAPI YAML file.")

(defface openapi-yaml-definition-type-face
  '((t (:inherit font-lock-type-face :weight bold)))
  "Face for a definition type in an OpenAPI YAML file."
  :group 'faces)

(defun openapi-yaml-mode--key (value)
  "Builds from a VALUE a regex string for a key that is not at the top level."
  (format "^[[:space:]-]+\\(%s\\)[[:space:]]*:[[:space:]]" value))

(defconst openapi-yaml-mode--space-or-quote "[[:space:]\"']")

(defun openapi-yaml-mode--string-constant (value)
  "Builds from a VALUE a regex string for a string constant."
  (format "\\(:\\|-\\)\\(%s*%s%s?\\)[[:space:]]*$"
          openapi-yaml-mode--space-or-quote value openapi-yaml-mode--space-or-quote))

(defun openapi-yaml-mode--string-constant-for-key (value key)
  "Builds from a VALUE a regex string for a string constant that is used with a
specific KEY."
  (format "^[[:space:]]*[:-]?[[:space:]]*%s[[:space:]]*\\(:\\|-\\)[[:space:]]*\n?[[:space:]]*\\(%s*%s%s?\\)[[:space:]]*$"
          key openapi-yaml-mode--space-or-quote value openapi-yaml-mode--space-or-quote))

(defvar openapi-yaml-mode--font-lock-keywords
  `(
    ;; Url paths and reference paths share the same syntax highlight
    ;; Url path key for Paths
    ("^[[:space:]]*\\([\"\']?/[^[:space:]]*[\"\']?\\):[[:space:]]*$" 1 openapi-yaml-url-path-face)
    ;; Url path value for host
    ("^host[[:space:]]*:[[:space:]]\\(.*\\)$" 1 openapi-yaml-url-path-face)
    ;; Url path value for basePath
    ("^basePath[[:space:]]*:[[:space:]]\\(.*\\)$" 1 openapi-yaml-url-path-face)
    ;; Path to a definition
    (,(format "%s?#/[^\"\n\']*%s?[[:space:]]*$" openapi-yaml-mode--space-or-quote openapi-yaml-mode--space-or-quote)
     . font-lock-string-face)
    ;; Url values
    ("[ \t]\\([\'\"]https?:[^[:space:]\"']*[\'\"]\\)[[:space:],]" 1 font-lock-string-face)
    ("[ \t\"']\\(https?:[^[:space:]\"']*\\)[[:space:],\"']" 1 font-lock-string-face)
    ;; Generic path (might be an url path or a file path)
    ;;("[[:space:]]*[\"\'`]?[^/]+/[^/[:space:]]+/[^/[:space:]][^[:space:]]*" . font-lock-string-face)

    ;; MIME types and formats share the same font face
    ("[ \t'\"`]\\(application/[^:\"\\'`[:space:]]*\\)" 1 font-lock-type-face)
    ("[ \t'\"`]\\(text/[^:\"\\'`[:space:]]*\\)" 1 font-lock-type-face)
    ("[ \t'\"`]\\(multipart/[^:\"\\'`[:space:]]*\\)" 1 font-lock-type-face)
    ("[ \t'\"`]\\(image/[^:\"\\'`[:space:]]*\\)" 1 font-lock-type-face)
    ("[ \t'\"`]\\(charset=[\"\\']?[^:\"\\'`[:space:]]*[\"\\']?\\)" 1 font-lock-type-face)
    ;; Types
    (,(openapi-yaml-mode--string-constant-for-key "\\(integer\\|number\\|string\\|boolean\\|array\\|object\\)" "type") 2 font-lock-type-face)
    ;; Formats
    (,(openapi-yaml-mode--string-constant-for-key "\\(int32\\|int64\\|float\\double\\|byte\\|binary\\|date\\|date-time\\|password\\)" "format") 2 font-lock-type-face)
    ;; Collection formats
    (,(openapi-yaml-mode--string-constant-for-key "\\(csv\\|ssv\\|tsv\\|pipes\\|multi\\)" "collectionFormat") 2 font-lock-type-face)

    ;; Markdown syntax highlight
    ;; Markdown header
    ("^[ \t]+#+[[:space:]]*\\(.*\\)$" 1 openapi-yaml-markdown-header-face)
    ;; Markdown link []
    ("\\([[][^]]*[]]\\)\\(([^[:space:]]*)\\)" 1 font-lock-keyword-face)
    ;; Markdown link ()
    ("\\([[][^]]*[]]\\)\\(([^[:space:]]*)\\)" 2 font-lock-string-face)
    ;; Markdown bold
    ("[ \t_]\\*\\*\\([^\\*]*\\)\\*\\*[ \t_]" 1 openapi-yaml-markdown-bold-face append)
    ("[ \t\\*]__\\([^\\_]*\\)__[ \t\\*]" 1 openapi-yaml-markdown-bold-face append)
    ;; Markdown italic
    ("[ \t_]\\*\\([^\\*[:space:]][^\\*]*\\)\\*[ \t_]" 1 openapi-yaml-markdown-italic-face append)
    ("[ \t\\*]_\\([^_[:space:]][^_]*\\)_[ \t\\*]" 1 openapi-yaml-markdown-italic-face append)
    ;; Markdown tables
    ("\\(.*\\)[\r]?[\n][ \t]*|[ \t]?--.*|[ \t]*$" 1 openapi-yaml-markdown-table-bold-face t)

    ;; YAML comments (Markdown headers cannot be declared without some indentation)
    ("^#[[:space:]]*.*$" . font-lock-comment-face)
    ;; XML comments
    ("<!--\\([[:space:]]\\|.\\)*?-->" . font-lock-comment-face)

    ;; HTTP Status Codes as keys
    ("^[[:space:]]*[\"']?[1-5][0-9][0-9][\"']?[[:space:]]*:[[:space:]]*$" . openapi-yaml-http-code-face)

    ;; HTTP methods as keys
    (,(openapi-yaml-mode--key "\\(get\\|put\\|post\\|delete\\|options\\|head\\|patch\\)") 1 openapi-yaml-http-method-face)

    ;; Highlight for numbers
    ("[ \t]\\(-?[[:digit:]]*\\.?[[:digit:]]*\\),?[[:space:]]+" 1 font-lock-constant-face)

    ;; Highlight null, true and false
    ("[ \t]\\(null\\|true\\|false\\)[[:space:],]" 1 font-lock-constant-face)

    ;; Pattern regex syntax highlight
    ("pattern[[:space:]]*:[[:space:]]*\\([^[:space:]]*\\)" 1 font-lock-string-face)
    ("pattern[[:space:]]*:[[:space:]]*[^[:space:]]*?\\[\\(\\^\\)" 1 font-lock-keyword-face t)

    ;; Highlight for constant values based on the key
    (,(openapi-yaml-mode--string-constant "\\(http\\|https\\|ws\\|wss\\)") 2 font-lock-constant-face)
    (,(openapi-yaml-mode--string-constant-for-key "\\(query\\|header\\|path\\|formData\\|body\\)" "-?[[:space:]]*in") 2 font-lock-constant-face)
    (,(openapi-yaml-mode--string-constant-for-key "\\(basic\\|apiKey\\|oauth2\\)" "type") 2 font-lock-constant-face)
    (,(openapi-yaml-mode--string-constant-for-key "\\(query\\|header\\)" "in") 2 font-lock-constant-face)
    (,(openapi-yaml-mode--string-constant-for-key "\\(implicit\\|password\\|application\\|accessCode\\)" "flow") 2 font-lock-constant-face)

    ;; Highlight operationId just like an url path
    (,(openapi-yaml-mode--string-constant-for-key "\\([^[:space:]:][^[:space:]]*\\)" "operationId") 2 openapi-yaml-url-path-face)

    ;; Escape characters
    ("\\([\\]\\)\\([tbnrf\'\"\\]\\)"
     (1 font-lock-comment-face t)
     (2 font-lock-keyword-face t))

    ;; YAML key (YAML keys in Swagger files shouldn't include spaces)
    ;; This allows to avoid many false positives when a sentence includes a :
    ("^[ \t-]*\\([^/[:space:]:][^[:space:]:]*\\)[ \t-]*:[ \t-\r\n]" 1 font-lock-variable-name-face)

    ;; YAML key for OAuth scopes
    ("^[ \t-]*\'\\([^/[:space:]][^[:space:]]*\\)[ \t-]*\':[ \t-\r\n]" 1 font-lock-variable-name-face)

    ;; HTTP headers
    ("[ \t\\'\"`]\\(Accept\\|Accept-Charset\\|Accept-Encoding\\|Accept-Language\\|Accept-Datetime\\|Authorization\\|Cache-Control\\|Content-Type\\):[ \t]" 1 font-lock-constant-face)

    ;; HTTP versions
    ("HTTP/1.[10]" . font-lock-constant-face)

    ;; HTTP methods in text before an url path
    ("\\(GET\\|PUT\\|POST\\|DELETE\\|OPTIONS\\|HEAD\\|PATCH\\)[ \t]*\\(/[^[:space:]]*\\|http\\)"
     (1 openapi-yaml-http-method-face)
     (2 openapi-yaml-path-face))

    ;; Query params in url paths
    ("/\\({[^}/[:space:]]*}\\)" 1 font-lock-keyword-face t)

    ;; Curl command
    ("[ \t]curl[ \t]" . font-lock-function-name-face)
    ("[ \t]-X[ \t]*\\(GET\\|PUT\\|POST\\|DELETE\\|OPTIONS\\|HEAD\\|PATCH\\)[ \t]*" 1 openapi-yaml-http-method-face)
    ;; Path to a parameter
    (,(format "%s?#/parameters/\\([^\"\n\']*\\)%s?[[:space:]]*$" openapi-yaml-mode--space-or-quote openapi-yaml-mode--space-or-quote)
     1 font-lock-keyword-face t)))

(defvar openapi-yaml-mode--font-lock-keywords-for-openapi
  (append openapi-yaml-mode--font-lock-keywords
          `((,(format "%s?#/definitions/\\([^\"\n\']*\\)%s?[[:space:]]*$" openapi-yaml-mode--space-or-quote openapi-yaml-mode--space-or-quote)
             1 openapi-yaml-definition-type-face t))))

(defvar openapi-yaml-mode--font-lock-keywords-for-openapi3
  (append openapi-yaml-mode--font-lock-keywords
          `((,(format "%s?#/components/schemas/\\([^\"\n\']*\\)%s?[[:space:]]*$" openapi-yaml-mode--space-or-quote openapi-yaml-mode--space-or-quote)
             1 openapi-yaml-definition-type-face t))))

  ;;;###autoload
(define-derived-mode openapi-yaml-mode
  yaml-mode "OpenAPI-YAML"
  ;; Swagger specification is case sensitive
  ;;  (setq font-lock-keywords-case-fold-search t)

  (unless openapi-yaml-use-yaml-mode-syntax-highlight
    (progn
      (set-syntax-table openapi-yaml-mode--syntax-table)

      (set (make-local-variable 'font-lock-defaults)
           (if (openapi-yaml-mode-detect-openapi2)
               '(openapi-yaml-mode--font-lock-keywords-for-openapi nil nil)
             '(openapi-yaml-mode--font-lock-keywords-for-openapi3 nil nil)))))

  (add-to-list 'completion-at-point-functions
               (if (openapi-yaml-mode-detect-openapi2)
                   'openapi-yaml-mode--openapi2-completion-at-point
                 'openapi-yaml-mode--openapi3-completion-at-point)))

(defun openapi-yaml-mode-detect-openapi2()
  (and
   (or (string-suffix-p ".yaml" (buffer-name))
       (string-suffix-p ".yml" (buffer-name)))
   (string-match
    "\\(.\\|\n\\)*\\([[:space:]]\\|\"\\|\\'\\)*swagger\\([[:space:]]\\|\"\\|\\'\\)*:[[:space:]]*[\"\\']2.0[\"\\'].*"
    ;; Need to avoid stack overflow for multi-line regex
    (buffer-substring 1 (min (buffer-size)
                             openapi-yaml-predicate-regexp-match-limit)))))

(defun openapi-yaml-mode-detect-openapi3()
  (and
   (or (string-suffix-p ".yaml" (buffer-name))
       (string-suffix-p ".yml" (buffer-name)))
   (string-match
    "\\(.\\|\n\\)*\\([[:space:]]\\|\"\\|\\'\\)*openapi\\([[:space:]]\\|\"\\|\\'\\)*:[[:space:]]*[\"\\']?3.0.0[\"\\']?.*"
    ;; Need to avoid stack overflow for multi-line regex
    (buffer-substring 1 (min (buffer-size)
                             openapi-yaml-predicate-regexp-match-limit)))))

(defun openapi-yaml-mode-add-to-magic-mode-alist ()
  "Associate YAML files with an openapi or swagger element to openapi2-yaml-mode."
  (add-to-list 'magic-mode-alist
               '(openapi-yaml-mode-detect-openapi2 . openapi-yaml-mode))
  (add-to-list 'magic-mode-alist
               '(openapi-yaml-mode-detect-openapi3 . openapi-yaml-mode)))

(setq yaml-imenu-generic-expression
      '(("*Elements*" "^ ? ?\\(:?[a-zA-Z_-]+\\):" 1)
        ("*Paths*" "^[[:space:]]*[\\'\"]?\\(/[^:[:space:]]*\\)" 1)
        ("*OperationIds*" "^[[:space:]]*[\\'\"]?operationId[\\'\"]?[[:space:]]*:[[:space:]]*[\\'\"]?\\([^\\'\"[:space:]]*\\)[\\'\"]?" 1)))

(provide 'openapi-yaml-mode)
;;; openapi-yaml-mode.el ends here
