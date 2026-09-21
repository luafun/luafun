#
# Makefile for generating documentation from EmmyLua annotations
# with emmylua_doc_cli and Sphinx (MyST).
#

BUILD_DIR  := build
SITE_DIR   := site
DOC_DIR    := doc

# Path to emmylua_doc_cli (override to use a custom build)
EMMYLUA_DOC_CLI ?= emmylua_doc_cli

# Sphinx source tree assembled from doc/ and the generated markdown
SPHINX_SRC := $(BUILD_DIR)/sphinx
SPHINX_RST := index.rst intro.rst getting_started.rst \
              under_the_hood.rst about.rst reference.rst

# Site URL used for the canonical link (set by CI; empty for local builds)
SITE_URL ?=
export SITE_URL

.PHONY: all docs api-docs sphinx-src check-tools serve deps check test clean

all: docs

## Check that $(EMMYLUA_DOC_CLI) is recent enough to render descriptions
check-tools:
	@v=`$(EMMYLUA_DOC_CLI) --version 2>/dev/null | sed -n 's/.* \([0-9][0-9]*\.[0-9][0-9]*\).*/\1/p'`; \
	if [ -z "$$v" ]; then \
		echo "error: cannot run '$(EMMYLUA_DOC_CLI) --version'"; \
		echo "       set EMMYLUA_DOC_CLI=/path/to/emmylua_doc_cli"; \
		exit 1; \
	fi; \
	major=$${v%%.*}; minor=$${v#*.}; \
	if [ "$$major" -eq 0 ] && [ "$$minor" -lt 25 ]; then \
		echo "error: emmylua_doc_cli $$v is too old; >= 0.25 is required"; \
		echo "       set EMMYLUA_DOC_CLI=/path/to/emmylua_doc_cli"; \
		exit 1; \
	fi

## Export EmmyLua annotations from fun.lua to markdown in $(BUILD_DIR)
api-docs: check-tools
	rm -rf $(BUILD_DIR)
	$(EMMYLUA_DOC_CLI) . -f markdown --ignore "tests/**,repro/**" -o $(BUILD_DIR)

## Assemble the Sphinx source tree from doc/ and the generated markdown
sphinx-src: api-docs
	mkdir -p $(SPHINX_SRC)
	cp $(addprefix $(DOC_DIR)/,$(SPHINX_RST)) $(DOC_DIR)/conf.py $(DOC_DIR)/logo.png $(SPHINX_SRC)/
	cp -r $(DOC_DIR)/_templates $(DOC_DIR)/_static $(SPHINX_SRC)/
	cp -r $(BUILD_DIR)/docs/. $(SPHINX_SRC)/
	rm -f $(SPHINX_SRC)/index.md
	python3 $(DOC_DIR)/split_api.py $(SPHINX_SRC) $(CURDIR)/fun.lua

## Build the documentation site with Sphinx
docs: sphinx-src
	rm -rf $(SITE_DIR)
	sphinx-build -b html $(SPHINX_SRC) $(SITE_DIR)

## Serve the documentation locally
serve: sphinx-src
	sphinx-autobuild --port 8080 $(SPHINX_SRC) $(SITE_DIR)

## Install python dependencies for the documentation build
deps:
	pip install sphinx==9.1.0 myst-parser==5.1.0 sphinx-autobuild

## Run static analysis with emmylua_check
check:
	emmylua_check .

## Run the test suite
test:
	cd tests && ./runtest *.lua

## Remove generated artifacts
clean:
	rm -rf $(BUILD_DIR) $(SITE_DIR)
