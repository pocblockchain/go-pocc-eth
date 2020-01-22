# This Makefile is meant to be used by people that do not usually work
# with Go source code. If you know what GOPATH is then you probably
# don't need to bother with make.

.PHONY: pocc android ios pocc-cross swarm evm all test clean
.PHONY: pocc-linux pocc-linux-386 pocc-linux-amd64 pocc-linux-mips64 pocc-linux-mips64le
.PHONY: pocc-linux-arm pocc-linux-arm-5 pocc-linux-arm-6 pocc-linux-arm-7 pocc-linux-arm64
.PHONY: pocc-darwin pocc-darwin-386 pocc-darwin-amd64
.PHONY: pocc-windows pocc-windows-386 pocc-windows-amd64

GOBIN = $(shell pwd)/build/bin
GO ?= latest

pocc:
	build/env.sh go run build/ci.go install ./cmd/pocc
	@echo "Done building."
	@echo "Run \"$(GOBIN)/pocc\" to launch pocc."

swarm:
	build/env.sh go run build/ci.go install ./cmd/swarm
	@echo "Done building."
	@echo "Run \"$(GOBIN)/swarm\" to launch swarm."

all:
	build/env.sh go run build/ci.go install

android:
	build/env.sh go run build/ci.go aar --local
	@echo "Done building."
	@echo "Import \"$(GOBIN)/pocc.aar\" to use the library."

ios:
	build/env.sh go run build/ci.go xcode --local
	@echo "Done building."
	@echo "Import \"$(GOBIN)/Geth.framework\" to use the library."

test: all
	build/env.sh go run build/ci.go test

clean:
	rm -fr build/_workspace/pkg/ $(GOBIN)/*

# The devtools target installs tools required for 'go generate'.
# You need to put $GOBIN (or $GOPATH/bin) in your PATH to use 'go generate'.

devtools:
	env GOBIN= go get -u golang.org/x/tools/cmd/stringer
	env GOBIN= go get -u github.com/jteeuwen/go-bindata/go-bindata
	env GOBIN= go get -u github.com/fjl/gencodec
	env GOBIN= go install ./cmd/abigen

# Cross Compilation Targets (xgo)

pocc-cross: pocc-linux pocc-darwin pocc-windows pocc-android pocc-ios
	@echo "Full cross compilation done:"
	@ls -ld $(GOBIN)/pocc-*

pocc-linux: pocc-linux-386 pocc-linux-amd64 pocc-linux-arm pocc-linux-mips64 pocc-linux-mips64le
	@echo "Linux cross compilation done:"
	@ls -ld $(GOBIN)/pocc-linux-*

pocc-linux-386:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/386 -v ./cmd/pocc
	@echo "Linux 386 cross compilation done:"
	@ls -ld $(GOBIN)/pocc-linux-* | grep 386

pocc-linux-amd64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/amd64 -v ./cmd/pocc
	@echo "Linux amd64 cross compilation done:"
	@ls -ld $(GOBIN)/pocc-linux-* | grep amd64

pocc-linux-arm: pocc-linux-arm-5 pocc-linux-arm-6 pocc-linux-arm-7 pocc-linux-arm64
	@echo "Linux ARM cross compilation done:"
	@ls -ld $(GOBIN)/pocc-linux-* | grep arm

pocc-linux-arm-5:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm-5 -v ./cmd/pocc
	@echo "Linux ARMv5 cross compilation done:"
	@ls -ld $(GOBIN)/pocc-linux-* | grep arm-5

pocc-linux-arm-6:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm-6 -v ./cmd/pocc
	@echo "Linux ARMv6 cross compilation done:"
	@ls -ld $(GOBIN)/pocc-linux-* | grep arm-6

pocc-linux-arm-7:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm-7 -v ./cmd/pocc
	@echo "Linux ARMv7 cross compilation done:"
	@ls -ld $(GOBIN)/pocc-linux-* | grep arm-7

pocc-linux-arm64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm64 -v ./cmd/pocc
	@echo "Linux ARM64 cross compilation done:"
	@ls -ld $(GOBIN)/pocc-linux-* | grep arm64

pocc-linux-mips:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mips --ldflags '-extldflags "-static"' -v ./cmd/pocc
	@echo "Linux MIPS cross compilation done:"
	@ls -ld $(GOBIN)/pocc-linux-* | grep mips

pocc-linux-mipsle:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mipsle --ldflags '-extldflags "-static"' -v ./cmd/pocc
	@echo "Linux MIPSle cross compilation done:"
	@ls -ld $(GOBIN)/pocc-linux-* | grep mipsle

pocc-linux-mips64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mips64 --ldflags '-extldflags "-static"' -v ./cmd/pocc
	@echo "Linux MIPS64 cross compilation done:"
	@ls -ld $(GOBIN)/pocc-linux-* | grep mips64

pocc-linux-mips64le:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mips64le --ldflags '-extldflags "-static"' -v ./cmd/pocc
	@echo "Linux MIPS64le cross compilation done:"
	@ls -ld $(GOBIN)/pocc-linux-* | grep mips64le

pocc-darwin: pocc-darwin-386 pocc-darwin-amd64
	@echo "Darwin cross compilation done:"
	@ls -ld $(GOBIN)/pocc-darwin-*

pocc-darwin-386:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=darwin/386 -v ./cmd/pocc
	@echo "Darwin 386 cross compilation done:"
	@ls -ld $(GOBIN)/pocc-darwin-* | grep 386

pocc-darwin-amd64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=darwin/amd64 -v ./cmd/pocc
	@echo "Darwin amd64 cross compilation done:"
	@ls -ld $(GOBIN)/pocc-darwin-* | grep amd64

pocc-windows: pocc-windows-386 pocc-windows-amd64
	@echo "Windows cross compilation done:"
	@ls -ld $(GOBIN)/pocc-windows-*

pocc-windows-386:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=windows/386 -v ./cmd/pocc
	@echo "Windows 386 cross compilation done:"
	@ls -ld $(GOBIN)/pocc-windows-* | grep 386

pocc-windows-amd64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=windows/amd64 -v ./cmd/pocc
	@echo "Windows amd64 cross compilation done:"
	@ls -ld $(GOBIN)/pocc-windows-* | grep amd64
