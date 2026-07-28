ASLREF ?= ./scripts/aslref

# Checked-in specification sources, in dependency order around the generated
# decoder declarations.
ASL_SOURCES_BEFORE_DECODER := \
	asl/architecture.asl \
	asl/types.asl \
	asl/state.asl \
	asl/tile/state.asl \
	asl/scalar/operands.asl \
	asl/scalar/integer.asl \
	asl/scalar/control.asl \
	asl/scalar/memory.asl \
	asl/concurrency.asl \
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
	asl/tile/cube.asl \
	asl/tile/legality.asl

ASL_SOURCES_AFTER_DECODER := \
	asl/profiles/pto-v0.asl \
	asl/scalar/dispatch.asl

ASL_SOURCES := $(ASL_SOURCES_BEFORE_DECODER) $(ASL_SOURCES_AFTER_DECODER)

# Executable semantic tests, assembled after the specification.
ASL_TESTS := \
	tests/asl/state-tests.asl \
	tests/asl/scalar-tests.asl \
	tests/asl/tile-tests.asl \
	tests/asl/concurrency-tests.asl \
	tests/asl/profile-tests.asl \
	tests/asl/main.asl

SPEC := build/pto-spec.asl
DECODER_SPEC := build/decoders.asl
TEST_SPEC := build/pto-tests.asl

.PHONY: all setup build repo-check toolchain-check check test ci clean \
	print-asl-sources print-asl-tests

all: ci

setup:
	./scripts/setup-aslref

build: $(SPEC)

$(DECODER_SPEC): scripts/generate-asl-decoders spec/catalog/scalar-forms.json \
		spec/catalog/system-registers.json spec/catalog/tile-operations.json
	@mkdir -p build
	@./scripts/generate-asl-decoders > $@

$(SPEC): $(ASL_SOURCES) $(DECODER_SPEC) scripts/assemble-asl Makefile
	./scripts/assemble-asl $@ $(ASL_SOURCES_BEFORE_DECODER) $(DECODER_SPEC) $(ASL_SOURCES_AFTER_DECODER)

$(TEST_SPEC): $(SPEC) $(ASL_TESTS) scripts/assemble-asl Makefile
	./scripts/assemble-asl $@ $(SPEC) $(ASL_TESTS)

repo-check: $(SPEC)
	./scripts/check-repository

# Canary checks proving the pinned ASLRef distinguishes valid from invalid ASL1.
toolchain-check:
	ASLREF="$(ASLREF)" ./scripts/check-toolchain

check: $(SPEC)
	$(ASLREF) --type-check-strict --no-exec $(SPEC)

test: $(TEST_SPEC)
	$(ASLREF) --type-check-strict $(TEST_SPEC)

ci: repo-check toolchain-check check test

print-asl-sources:
	@printf '%s\n' $(ASL_SOURCES)

print-asl-tests:
	@printf '%s\n' $(ASL_TESTS)

clean:
	rm -rf build
