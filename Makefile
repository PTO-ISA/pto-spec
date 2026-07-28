ASLREF ?= ./scripts/aslref

ASL_SOURCES := \
	asl/architecture.asl \
	asl/types.asl \
	asl/state.asl \
	asl/tile/state.asl \
	asl/scalar/operands.asl \
	asl/scalar/integer.asl \
	asl/scalar/control.asl \
	asl/scalar/memory.asl \
	asl/scalar/addressing.asl \
	asl/scalar/atomic.asl \
	asl/scalar/system.asl \
	asl/scalar/system-registers.asl \
	asl/scalar/floating.asl \
	asl/tile/management.asl \
	asl/tile/elementwise.asl \
	asl/tile/reduction.asl \
	asl/tile/expansion.asl \
	asl/tile/generation.asl \
	asl/tile/conversion.asl \
	asl/tile/rearrangement.asl \
	asl/tile/complex.asl \
	asl/tile/memory.asl \
	asl/tile/cube.asl

SPEC := build/pto-spec.asl
DECODER_SPEC := build/decoders.asl
TEST_SPEC := build/pto-tests.asl
ASL_TEST_SOURCES := \
	tests/asl/state-tests.asl \
	tests/asl/scalar-tests.asl \
	tests/asl/tile-tests.asl \
	tests/asl/main.asl

.PHONY: all setup build repo-check check test ci clean

all: ci

setup:
	./scripts/setup-aslref

build: $(SPEC)

$(DECODER_SPEC): scripts/generate-asl-decoders spec/catalog/scalar-forms.json \
		spec/catalog/system-registers.json spec/catalog/tile-operations.json
	@mkdir -p build
	@./scripts/generate-asl-decoders > $@

$(SPEC): $(ASL_SOURCES) $(DECODER_SPEC) Makefile
	@mkdir -p build
	@{ \
		echo "// Generated from the ordered PTO ASL sources. Do not edit."; \
		for source in $(ASL_SOURCES); do \
			echo; \
			echo "// Source: $$source"; \
			cat "$$source"; \
		done; \
		cat $(DECODER_SPEC); \
	} > $@

check: $(SPEC)
	$(ASLREF) --type-check-strict --no-exec $(SPEC)

$(TEST_SPEC): $(SPEC) $(ASL_TEST_SOURCES) Makefile
	@{ \
		cat $(SPEC); \
		for source in $(ASL_TEST_SOURCES); do \
			echo; \
			echo "// Test source: $$source"; \
			cat "$$source"; \
		done; \
	} > $@

test: $(TEST_SPEC)
	$(ASLREF) --type-check-strict $(TEST_SPEC)

repo-check:
	./scripts/check-repository

ci: repo-check check test

clean:
	rm -rf build
