ASLREF ?= ./scripts/aslref

ASL_SOURCES := asl/architecture.asl

SPEC := build/pto-spec.asl

.PHONY: all setup build repo-check check ci clean

all: ci

setup:
	./scripts/setup-aslref

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

repo-check:
	./scripts/check-repository

ci: repo-check check

clean:
	rm -rf build
