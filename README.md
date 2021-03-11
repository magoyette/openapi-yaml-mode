# OpenAPI YAML Mode

An Emacs major mode for [OpenAPI](https://github.com/OAI/OpenAPI-Specification) YAML files. OpenAPI YAML mode supports OpenAPI 2 and 3. OpenAPI 2 files are identical to the [Swagger](https://swagger.io/) 2 files.

OpenAPI YAML mode is based on [yaml-mode](https://github.com/yoshiki/yaml-mode), but uses a different strategy for syntax highlight that takes into consideration the OpenAPI specification.

OpenAPI YAML mode is under initial development and is not yet stable.

## Features

- Syntax highlight based on the OpenAPI specification (version 2 and 3).
- Basic completion with `completion-at-point`. Works with [Company](https://company-mode.github.io/) through the CAPF back-end.
- [IMenu](https://www.gnu.org/software/emacs/manual/html_node/emacs/Imenu.html)
  for paths and operationIds.

## Complementary packages

- Swagger 2 validation can be added with [flycheck-swagger-cli](https://github.com/magoyette/flycheck-swagger-cli).

## Customizations

### Use the yaml-mode syntax highlight

The defcustom variable `openapi-yaml-use-yaml-mode-syntax-highlight` can be used to
disable the OpenAPI syntax highlight of OpenAPI YAML Mode. The default syntax
highlight of [yaml-mode](https://github.com/yoshiki/yaml-mode) is used instead.

```emacs-lisp
(setq openapi-yaml-use-yaml-mode-syntax-highlight t)
```
