# makefile for BacTra

include make/projgen.make

ifeq (,$(NO_FORMAT_MAKE))
include make/format.make
endif

include make/genie.make
include make/fullbuild.make
include make/unittest.make
include make/cicd.make
