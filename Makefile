PROJECT_NAME    ?= yv
DIR_BUILD	?= build
DIR_DIST	?= dist
GENERATOR	?= Ninja

UNAME_S	:= $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
    APP_DEV	:= $(DIR_BUILD)/$(PROJECT_NAME).app
	APP_DIST := $(DIR_DIST)/$(PROJECT_NAME).app
else
	APP_DEV := $(DIR_BUILD)/$(PROJECT_NAME)
	APP_DIST := $(DIR_DIST)/$(PROJECT_NAME)
endif

.PHONY: all dev build clean

all: dev

dev:
	@cmake -S . -B $(DIR_BUILD) -G $(GENERATOR) -DCMAKE_BUILD_TYPE=Debug -DCMAKE_POLICY_VERSION_MINIMUM=3.10
	@cmake --build $(DIR_BUILD)
	@open -n ./$(APP_DEV)

build:
	@cmake -S . -B $(DIR_BUILD) -G $(GENERATOR) -DCMAKE_BUILD_TYPE=Release -DCMAKE_POLICY_VERSION_MINIMUM=3.10
	@cmake --build $(DIR_BUILD)
	@cmake --install $(DIR_BUILD) --prefix $(DIR_DIST)
	@open -n ./$(APP_DIST)

clean:
	@rm -rf .cache $(DIR_BUILD) $(DIR_DIST)