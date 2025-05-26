## unit test rules

bin/$(HOST_OS)/hello \
bin/$(HOST_OS)/unittest    : build

hello: bin/$(HOST_OS)/hello
	pwd
	echo $<
	ls -alG $<
	$< | tee $@.log

unittest: bin/$(HOST_OS)/unittest
	pwd
	echo $<
	ls -alG $<
	$< | tee $@.log


functionalitytests:       \
	hello

unittests:                \
	unittest

