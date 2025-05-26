#
# Copyright 2020~ Christian Helmich. All rights reserved.
# License: http://www.opensource.org/licenses/BSD-2-Clause
#

UNAME := $(shell uname)
ifeq ($(UNAME),$(filter $(UNAME),Linux Darwin SunOS FreeBSD GNU/kFreeBSD NetBSD OpenBSD GNU))
ifeq ($(UNAME),$(filter $(UNAME),Darwin))
HOST_OS=darwin
TARGET_OS?=darwin
else
ifeq ($(UNAME),$(filter $(UNAME),SunOS))
HOST_OS=solaris
TARGET_OS?=solaris
else
ifeq ($(UNAME),$(filter $(UNAME),FreeBSD GNU/kFreeBSD NetBSD OpenBSD))
HOST_OS=bsd
TARGET_OS?=bsd
else
HOST_OS=linux
TARGET_OS?=linux
endif
endif
endif
else
EXE=.exe
HOST_OS=windows
TARGET_OS?=windows
endif

CP=rclone copy -P

.PHONY: release

## just provide genie on the command line
GENIE?=bin/$(HOST_OS)/genie$(EXE)


## main target
MAINTARGET=bin/$(TARGET_OS)/hellocpp$(EXE)

SILENT?=@

GENIE_OPTIONS?=

PROJECT_TYPE?=ninja

CONFIG?=debug

COMPILER?=clang


## default rules

$(MAINTARGET).$(PROJECT_TYPE): build/$(COMPILER).$(PROJECT_TYPE).$(TARGET_OS)
	$(SILENT) $(MAKE) -C build/$(COMPILER).$(PROJECT_TYPE).$(TARGET_OS) GENIE_OPTIONS=$(GENIE_OPTIONS) config=$(CONFIG)

all: clean projgen $(MAINTARGET).$(PROJECT_TYPE)


## clean up rules

clean:
	$(SILENT) $(MAKE) -C build/$(COMPILER).$(PROJECT_TYPE).$(TARGET_OS) config=$(CONFIG) clean

clean-projects:
	$(SILENT) rm -rf build/$(COMPILER).$(PROJECT_TYPE).$(TARGET_OS)

clean-all-projects:
	$(SILENT) rm -rf build/$(COMPILER).$(PROJECT_TYPE).*
	$(SILENT) rm -rf build/xcode.*
	$(SILENT) rm -rf build/vs.*

clean-artifacts:
	$(SILENT) rm -rf build/bin/$(TARGET_OS)
	$(SILENT) rm -rf build/obj/$(TARGET_OS)

clean-all-artifacts:
	$(SILENT) rm -rf build/bin/
	$(SILENT) rm -rf build/obj/


## project generation rules

pinfo:
	$(SILENT) echo CC: $(COMPILER)

p projgen: pinfo clean-all-projects projgen-$(TARGET_OS)
	@echo re-generated projects

projgen-os: pinfo update-genie-os projgen-$(TARGET_OS)

projgen-xcode build/xcode.darwin:
	$(SILENT) $(GENIE) --to=../build/xcode.darwin            --toolchain=macosx  --os=macosx   --cc=$(COMPILER) --platform=universal   $(GENIE_OPTIONS) xcode10

projgen-vs build/vs.windows:
	$(SILENT) $(GENIE) --to=../build/vs.windows              --toolchain=windows --os=windows             --platform=x64         $(GENIE_OPTIONS) vs2019

projgen-win projgen-win64 projgen-windows:	build/$(COMPILER).$(PROJECT_TYPE).windows

projgen-linux:	build/$(COMPILER).$(PROJECT_TYPE).linux

projgen-asmjs:	build/$(COMPILER).$(PROJECT_TYPE).asmjs

projgen-wasm:	build/$(COMPILER).$(PROJECT_TYPE).wasm

projgen-macosx projgen-macos projgen-osx projgen-darwin:	build/$(COMPILER).$(PROJECT_TYPE).darwin


# GCC
build/gcc.$(PROJECT_TYPE).windows:
	$(SILENT) $(GENIE) --to=../build/gcc.$(PROJECT_TYPE).windows --toolchain=windows --os=windows  --cc=gcc --platform=x64         $(GENIE_OPTIONS) $(PROJECT_TYPE)
ifeq (ninja,$(PROJECT_TYPE))
ifeq (darwin,$(HOST_OS))
	$(SILENT) sed -i "" -e "s|cmd\ /c|bash -c|g" build/gcc.ninja.windows/*/*.ninja
else
ifeq (linux,$(HOST_OS))
	$(SILENT) sed -i -e "s|cmd\ /c|bash -c|g" build/gcc.ninja.windows/*/*.ninja
endif
endif
endif

build/gcc.$(PROJECT_TYPE).linux:
	$(SILENT) $(GENIE) --to=../build/gcc.$(PROJECT_TYPE).linux   --toolchain=linux   --os=linux    --cc=gcc                        $(GENIE_OPTIONS) $(PROJECT_TYPE)

build/gcc.$(PROJECT_TYPE).asmjs:
	$(SILENT) $(GENIE) --to=../build/gcc.$(PROJECT_TYPE).asmjs   --toolchain=asmjs   --os=linux    --cc=gcc                        $(GENIE_OPTIONS) $(PROJECT_TYPE)

build/gcc.$(PROJECT_TYPE).wasm:
	$(SILENT) $(GENIE) --to=../build/gcc.$(PROJECT_TYPE).wasm    --toolchain=wasm    --os=linux    --cc=gcc                        $(GENIE_OPTIONS) $(PROJECT_TYPE)

build/gcc.$(PROJECT_TYPE).darwin:
	$(SILENT) $(GENIE) --to=../build/gcc.$(PROJECT_TYPE).darwin  --toolchain=macosx  --os=macosx   --cc=gcc  --platform=universal  $(GENIE_OPTIONS) $(PROJECT_TYPE)

# Clang
build/clang.$(PROJECT_TYPE).windows:
	$(SILENT) $(GENIE) --to=../build/clang.$(PROJECT_TYPE).windows --toolchain=windows --os=windows  --cc=clang --platform=x64         $(GENIE_OPTIONS) $(PROJECT_TYPE)
ifeq (ninja,$(PROJECT_TYPE))
ifeq (darwin,$(HOST_OS))
	$(SILENT) sed -i "" -e "s|cmd\ /c|bash -c|g" build/clang.ninja.windows/*/*.ninja
else
ifeq (linux,$(HOST_OS))
	$(SILENT) sed -i -e "s|cmd\ /c|bash -c|g" build/clang.ninja.windows/*/*.ninja
endif
endif
endif

build/clang.$(PROJECT_TYPE).linux:
	$(SILENT) $(GENIE) --to=../build/clang.$(PROJECT_TYPE).linux   --toolchain=linux   --os=linux    --cc=clang                        $(GENIE_OPTIONS) $(PROJECT_TYPE)

build/clang.$(PROJECT_TYPE).asmjs:
	$(SILENT) $(GENIE) --to=../build/clang.$(PROJECT_TYPE).asmjs   --toolchain=asmjs   --os=linux    --cc=clang                        $(GENIE_OPTIONS) $(PROJECT_TYPE)

build/clang.$(PROJECT_TYPE).wasm:
	$(SILENT) $(GENIE) --to=../build/clang.$(PROJECT_TYPE).wasm    --toolchain=wasm    --os=linux    --cc=clang                        $(GENIE_OPTIONS) $(PROJECT_TYPE)

build/clang.$(PROJECT_TYPE).darwin:
	$(SILENT) $(GENIE) --to=../build/clang.$(PROJECT_TYPE).darwin  --toolchain=macosx  --os=macosx   --cc=clang  --platform=universal  $(GENIE_OPTIONS) $(PROJECT_TYPE)

# Zig
build/zig.$(PROJECT_TYPE).windows:
	$(SILENT) $(GENIE) --to=../build/zig.$(PROJECT_TYPE).windows --toolchain=windows --os=windows  --cc=zig --zig-target=x86_64-windows-gnu       $(GENIE_OPTIONS) $(PROJECT_TYPE)
ifeq (ninja,$(PROJECT_TYPE))
ifeq (darwin,$(HOST_OS))
	$(SILENT) sed -i "" -e "s|cmd\ /c|bash -c|g" build/zig.ninja.windows/*/*.ninja
else
ifeq (linux,$(HOST_OS))
	$(SILENT) sed -i -e "s|cmd\ /c|bash -c|g" build/zig.ninja.windows/*/*.ninja
endif
endif
endif

build/zig.$(PROJECT_TYPE).linux:
	$(SILENT) $(GENIE) --to=../build/zig.$(PROJECT_TYPE).linux   --toolchain=linux   --os=linux    --cc=zig --zig-target=x86_64-linux-musl        $(GENIE_OPTIONS) $(PROJECT_TYPE)

build/zig.$(PROJECT_TYPE).asmjs:
	$(SILENT) $(GENIE) --to=../build/zig.$(PROJECT_TYPE).asmjs   --toolchain=asmjs   --os=linux    --cc=zig --zig-target=wasm32-freestanding-musl $(GENIE_OPTIONS) $(PROJECT_TYPE)

build/zig.$(PROJECT_TYPE).wasm:
	$(SILENT) $(GENIE) --to=../build/zig.$(PROJECT_TYPE).wasm    --toolchain=wasm    --os=linux    --cc=zig --zig-target=wasm32-wasi-musl         $(GENIE_OPTIONS) $(PROJECT_TYPE)

build/zig.$(PROJECT_TYPE).darwin:
	$(SILENT) $(GENIE) --to=../build/zig.$(PROJECT_TYPE).darwin  --toolchain=macosx  --os=macosx   --cc=zig --zig-target=x86_64-macos-gnu         $(GENIE_OPTIONS) $(PROJECT_TYPE)


## print genie
genie-help:
	$(SILENT) $(GENIE) $(GENIE_OPTIONS) --help

## release build rules

release-$(HOST_OS):
	$(SILENT) $(MAKE) -B rebuild CONFIG=release

release: release-$(TARGET_OS)


## build rules

build-$(TARGET_OS): loadpackages generate embed projgen-$(TARGET_OS) $(MAINTARGET).$(PROJECT_TYPE)

build: build-$(TARGET_OS)

rebuild: clean clean-artifacts projgen build

b: projgen build


## generation callbacks

embed:
	$(GENIE) embed

generate:
	$(GENIE) generate

refresh:
	$(GENIE) refresh

loadpackages:
	$(GENIE) loadpackages

## specific build rules

build-linux-zig:
	$(MAKE) build CC=zig TARGET_OS=linux CC="zig cc -target x86_64-linux-musl" CXX="zig c++ -target x86_64-linux-musl" AR="zig ar" RANLIB="zig ranlib" verbose=1

build-windows-zig:
	$(MAKE) build CC=zig TARGET_OS=windows CC="zig cc -target x86_64-windows-gnu" CXX="zig c++ -target x86_64-windows-gnu" AR="zig ar" RANLIB="zig ranlib" verbose=1

build-macos-zig build-darwin-zig:
	$(MAKE) build CC=zig TARGET_OS=darwin CC="zig cc -target x86_64-macos-gnu" CXX="zig c++ -target x86_64-macos-gnu" AR="zig ar" RANLIB="zig ranlib" verbose=1
	$(MAKE) -C build/gmake.darwin CC="zig cc -target aarch64-macos-gnu" CXX="zig c++ -target aarch64-macos-gnu" AR="zig ar" RANLIB="zig ranlib" verbose=1
