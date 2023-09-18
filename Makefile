GOCMD=$(shell which go)
GOTEST=$(GOCMD) test
GOVET=$(GOCMD) vet
BINARY_NAME=eyepop-mediamtx
VERSION?=1.1.0

GIT_COMMIT := $(shell git rev-list -1 HEAD)

GOPATH := $(shell $(GOCMD) env GOPATH)

GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
CYAN   := $(shell tput -Txterm setaf 6)
RESET  := $(shell tput -Txterm sgr0)

.PHONY: all build vendor

all: help

ifeq ($(PREFIX),)
    PREFIX := /usr
endif

## Build:
build: ## Build your project and put the output binary in out/bin/
	mkdir -p out/bin
	GO111MODULE=on $(GOCMD) build -mod vendor -o out/bin/$(BINARY_NAME) -ldflags "-X main.gitCommit=$(GIT_COMMIT) -X main.version=$(VERSION)" ./main.go
	mkdir -p out/config
	cp mediamtx.yml out/config/mediamtx.yml.example


clean: ## Remove build related file
	rm -fr ./bin
	rm -fr ./out
	rm -f ./junit-report.xml checkstyle-report.xml ./coverage.xml ./profile.cov yamllint-checkstyle.xml

vendor: ## Copy of all packages needed to support builds and tests in the vendor directory
	$(GOCMD) mod vendor

install:
	mkdir -p $(DESTDIR)$(PREFIX)/share/eyepop-ai/config/mediamtx
	mkdir -p $(DESTDIR)$(PREFIX)/bin

	cp out/config/mediamtx.yml.example $(DESTDIR)$(PREFIX)/share/eyepop-ai/config/mediamtx
	cp out/bin/eyepop-mediamtx $(DESTDIR)$(PREFIX)/bin

test:
	echo "nothing to test"

## Help:
help: ## Show this help.
	@echo ''
	@echo 'Usage:'
	@echo '  ${YELLOW}make${RESET} ${GREEN}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} { \
		if (/^[a-zA-Z_-]+:.*?##.*$$/) {printf "    ${YELLOW}%-20s${GREEN}%s${RESET}\n", $$1, $$2} \
		else if (/^## .*$$/) {printf "  ${CYAN}%s${RESET}\n", substr($$1,4)} \
		}' $(MAKEFILE_LIST)



