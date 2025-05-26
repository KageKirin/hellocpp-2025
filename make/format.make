## formatting makerules

ALL_SOURCE_FILES = \
	$(shell fd ".*\.h$$"     -- src)       \
	$(shell fd ".*\.c$$"     -- src)       \
	$(shell fd ".*\.hpp$$"   -- src)       \
	$(shell fd ".*\.cpp$$"   -- src)       \
	$(shell fd ".*\.inl$$"   -- src)


HAS_TRACKED_FILES = $(shell git ls-files -- src)
ALL_TRACKED_FILES = \
	$(shell git ls-files -- src | rg ".*\.h$$")         \
	$(shell git ls-files -- src | rg ".*\.c$$")         \
	$(shell git ls-files -- src | rg ".*\.hpp$$")       \
	$(shell git ls-files -- src | rg ".*\.cpp$$")       \
	$(shell git ls-files -- src | rg ".*\.inl$$")

HAS_MODIFIED_FILES = $(shell git ls-files -m -- src)
ALL_MODIFIED_FILES = \
	$(shell git ls-files -m -- src | rg ".*\.h$$")         \
	$(shell git ls-files -m -- src | rg ".*\.c$$")         \
	$(shell git ls-files -m -- src | rg ".*\.hpp$$")       \
	$(shell git ls-files -m -- src | rg ".*\.cpp$$")       \
	$(shell git ls-files -m -- src | rg ".*\.inl$$")

build-db: compile_commands.json

compile_commands.json:
	ninja -C build/ninja.darwin/$(CONFIG) -t compdb > $@

format-all: build-db _format-all
_format-all:
	clang-tidy --fix --fix-errors $(ALL_SOURCE_FILES)
	clang-format -i $(ALL_SOURCE_FILES)

f format: build-db _format
_format: $(HAS_TRACKED_FILES)
	clang-tidy --fix --fix-errors $(ALL_TRACKED_FILES)
	clang-format -i $(ALL_TRACKED_FILES)

t tidy: build-db _tidy
_tidy: $(HAS_MODIFIED_FILES)
	clang-tidy --fix --fix-errors $(ALL_MODIFIED_FILES)
	clang-format -i $(ALL_MODIFIED_FILES)

q qformat: build-db _qformat
_qformat: $(HAS_MODIFIED_FILES)
	clang-format -i $^
