PROJECT_NAME    ?= yv
DIR_BUILD	?= build
DIR_DIST	?= dist
GENERATOR	?= Ninja

WEB_DIR		?= www
WEB_SRC		?= $(WEB_DIR)/src
WEB_DIST	?= $(WEB_DIR)/dist
WEB_ASSETS_SRC	?= ${WEB_SRC}/assets
WEB_ASSETS_DIST	?= ${WEB_DIST}/assets
WEB_VENDOR_SRC	?= ${WEB_SRC}/vendor
WEB_VENDOR_DIST	?= ${WEB_DIST}/vendor
WEB_HTML_MAIN	?= index.html
WEB_SCRIPT_MAIN	?= main.ts
WEB_CSS_MAIN	?= style.css
ESBUILD		?= ${WEB_DIR}/dependencies/esbuild@v0.28.2/esbuild
WEB_TARGET	?= safari15

UNAME_S	:= $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
    APP_DEV	:= $(DIR_BUILD)/$(PROJECT_NAME).app
	APP_DIST := $(DIR_DIST)/$(PROJECT_NAME).app
else
	APP_DEV := $(DIR_BUILD)/$(PROJECT_NAME)
	APP_DIST := $(DIR_DIST)/$(PROJECT_NAME)
endif

.PHONY: all dev build webbuild clean

all: dev

dev:
	@$(MAKE) webbuild
	@cmake -S . -B $(DIR_BUILD) -G $(GENERATOR) -DCMAKE_BUILD_TYPE=Debug -DCMAKE_POLICY_VERSION_MINIMUM=3.10
	@cmake --build $(DIR_BUILD)
	@open -n ./$(APP_DEV)

build:
	@$(MAKE) webbuild
	@cmake -S . -B $(DIR_BUILD) -G $(GENERATOR) -DCMAKE_BUILD_TYPE=Release -DCMAKE_POLICY_VERSION_MINIMUM=3.10
	@cmake --build $(DIR_BUILD)
	@cmake --install $(DIR_BUILD) --prefix $(DIR_DIST)
	@open -n ./$(APP_DIST)

webbuild:
	@rm -rf "$(WEB_DIST)"
	@mkdir -p "$(WEB_DIST)"
	@$(ESBUILD) \
		"$(WEB_SRC)/$(WEB_SCRIPT_MAIN)" \
		"$(WEB_SRC)/${WEB_CSS_MAIN}" \
		--bundle \
		--minify \
		--platform=browser \
		--target=$(WEB_TARGET) \
		--outdir="$(WEB_DIST)"
	@cp "$(WEB_SRC)/$(WEB_HTML_MAIN)" "$(WEB_DIST)/$(WEB_HTML_MAIN)"
	@if [ -d "$(WEB_ASSETS_SRC)" ]; then \
		mkdir -p "$(WEB_ASSETS_DIST)"; \
		cp -R "$(WEB_ASSETS_SRC)/." "$(WEB_ASSETS_DIST)/"; \
	fi
	@if [ -d "$(WEB_VENDOR_SRC)" ]; then \
		mkdir -p "$(WEB_VENDOR_DIST)"; \
		cp -R "$(WEB_VENDOR_SRC)/." "$(WEB_VENDOR_DIST)/"; \
	fi

clean:
	@rm -rf .cache $(DIR_BUILD) $(DIR_DIST)