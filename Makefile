LOCAL_VERSION?=""
CI_RUN?=false
ADDITIONAL_BUILD_FLAGS=""
LDFLAGS=-s -w -X main.PKG_VERSION=${LOCAL_VERSION}

ifeq ($(CI_RUN), true)
	ADDITIONAL_BUILD_FLAGS="-test.short"
endif

ifneq ($(shell which semver-gen), "")
	LOCAL_VERSION="0.0.0-dev"
else
	LOCAL_VERSION=$(shell semver-gen generate -l -c config-release.yaml | sed -e 's|SEMVER ||g')
endif

.PHONY: help
help:  ## display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n\nTargets:\n"} /^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

.PHONY: all
all: build ## Build all targets

.PHONY: build
build: ## Build binary
	go build -o semver-gen -ldflags="-s -w -X main.PKG_VERSION=${LOCAL_VERSION}" *.go

# .PHONY: run
# run: build ## Build binary and execute it
# 	@./semver-gen

.PHONY: test
test: ## Run whole test suite
	@go test ./... $(ADDITIONAL_BUILD_FLAGS) -v -race -cover -coverprofile=coverage.out

.PHONY: update
update: ## Update dependencies
	@go mod download

.PHONY: update-all
update-all: ## Update all dependencies and sub-packages
	@go get -u ./...

dist-release: ## Build all binaries
	rm -fr dist/ || true
	mkdir -p dist/
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="$(LDFLAGS)" -a -installsuffix cgo -o dist/semver-gen-linux-amd64
	CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -ldflags="$(LDFLAGS)" -a -installsuffix cgo -o dist/semver-gen-linux-arm64
	CGO_ENABLED=0 GOOS=darwin go build -ldflags="$(LDFLAGS)" -a -installsuffix cgo -o dist/semver-gen-darwin-amd64
	CGO_ENABLED=0 GOOS=darwin GOARCH=arm64 go build -ldflags="$(LDFLAGS)" -a -installsuffix cgo -o dist/semver-gen-darwin-arm64
	CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go build -ldflags="$(LDFLAGS)" -a -installsuffix cgo -o dist/semver-gen-windows-amd64.exe