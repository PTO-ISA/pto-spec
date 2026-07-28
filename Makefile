ASLREF ?= aslref

ASL_SOURCES := asl/architecture.asl

SPEC := build/pto-spec.asl

.PHONY: all build check ci clean

all: ci

build: $(SPEC)

$(SPEC): $(ASL_SOURCES) Makefile
	@mkdir -p build
	@{ \
		echo "// Generated from the ordered PTO ASL sources. Do not edit."; \
		for source in $(ASL_SOURCES); do \
			echo; \
			echo "// Source: $$source"; \
			cat "$$source"; \
		done; \
	} > $@

check: $(SPEC)
	$(ASLREF) --type-check-strict --no-exec $(SPEC)

ci: check

clean:
	rm -rf build
