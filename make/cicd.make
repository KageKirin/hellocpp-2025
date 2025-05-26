## CI crossbuild makerules

### targeting host platform
ci-host-$(HOST_OS):
	$(MAKE) fullbuild unittests functionalitytests TARGET_OS=$(HOST_OS) COMPILER=clang PROJECT_TYPE=ninja CONFIG=$(CONFIG) || \
	$(MAKE) fullbuild unittests functionalitytests TARGET_OS=$(HOST_OS) COMPILER=clang PROJECT_TYPE=gmake CONFIG=$(CONFIG)
	$(MAKE) fullbuild unittests functionalitytests TARGET_OS=$(HOST_OS) COMPILER=zig PROJECT_TYPE=ninja CONFIG=$(CONFIG) || \
	$(MAKE) fullbuild unittests functionalitytests TARGET_OS=$(HOST_OS) COMPILER=zig PROJECT_TYPE=gmake CONFIG=$(CONFIG)

### cross-platform build rules
ci-cross-$(TARGET_OS):
	$(MAKE) fullbuild TARGET_OS=$(TARGET_OS) COMPILER=zig PROJECT_TYPE=ninja CONFIG=$(CONFIG) || \
	$(MAKE) fullbuild TARGET_OS=$(TARGET_OS) COMPILER=zig PROJECT_TYPE=gmake CONFIG=$(CONFIG)

### below would need another clang (e.g. not Xcode clang) to run.
### fails on linking
#	$(MAKE) fullbuild TARGET_OS=linux COMPILER=clang PROJECT_TYPE=ninja CONFIG=$(CONFIG) ||
#	$(MAKE) fullbuild TARGET_OS=linux COMPILER=clang PROJECT_TYPE=gmake CONFIG=$(CONFIG)


### makerule for host CI
ci-host: ci-host-$(HOST_OS)
ci-cross: ci-cross-$(TARGET_OS)


## docker images

### container without source files to use with volume mapping
ci-ubuntu-latest:
	yes | docker system prune
	docker build -t ubuntu-latest environments/ubuntu --progress=plain

### build from container with mapped volume
### takes longer to start up due to mapped filesystem operations being super slow
ci-docker-linux: ci-ubuntu-latest
	docker run --memory=6g --rm -v $(PWD):/home --name badass-latest ubuntu-latest make -C /home ci-host CONFIG=$(CONFIG)
	docker run --memory=6g --rm -v $(PWD):/home --name badass-latest ubuntu-latest make -C /home ci-cross TARGET_OS=darwin CONFIG=$(CONFIG)
	docker run --memory=6g --rm -v $(PWD):/home --name badass-latest ubuntu-latest make -C /home ci-cross TARGET_OS=windows CONFIG=$(CONFIG)

## 'full-ci' rules
## inclusive makerules to test all possible configurations
## will take some time

ifeq (linux,$(HOST_OS))
full-ci-cross:
	$(MAKE) ci-cross TARGET_OS=darwin  CONFIG=$(CONFIG)
	$(MAKE) ci-cross TARGET_OS=windows CONFIG=$(CONFIG)
endif

ifeq (darwin,$(HOST_OS))
full-ci-cross:
	$(MAKE) ci-cross TARGET_OS=linux   CONFIG=$(CONFIG)
	$(MAKE) ci-cross TARGET_OS=windows CONFIG=$(CONFIG)
endif

ifeq (windows,$(HOST_OS))
full-ci-cross:
	$(MAKE) ci-cross TARGET_OS=darwin  CONFIG=$(CONFIG)
	$(MAKE) ci-cross TARGET_OS=linux   CONFIG=$(CONFIG)
endif


full-ci:           \
	ci-host        \
	full-ci-cross

blue-ci:
	$(MAKE) full-ci CONFIG=Debug
	$(MAKE) full-ci CONFIG=Release
