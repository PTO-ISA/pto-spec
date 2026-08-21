ASLREF ?= ./scripts/aslref

# Checked-in specification sources, in dependency order around the generated
# decoder declarations.
ASL_SOURCES_BEFORE_DECODER := \
	asl/architecture.asl \
	asl/types.asl \
	asl/bundle/postprocess.asl \
	asl/numeric/formats/fp64.asl \
	asl/numeric/formats/fp32.asl \
	asl/numeric/formats/tf32.asl \
	asl/numeric/formats/hf32.asl \
	asl/numeric/formats/fp16.asl \
	asl/numeric/formats/bf16.asl \
	asl/numeric/formats/e4m3.asl \
	asl/numeric/formats/e5m2.asl \
	asl/numeric/formats/e3m2.asl \
	asl/numeric/formats/e2m3.asl \
	asl/numeric/formats/hif8.asl \
	asl/numeric/formats/e2m1x2.asl \
	asl/numeric/formats/e1m2x2.asl \
	asl/numeric/formats/hif4x2.asl \
	asl/numeric/formats/e8m0.asl \
	asl/numeric/formats.asl \
	asl/state.asl \
	asl/bundle/state.asl \
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
	asl/bundle/dispatch.asl \
	asl/scalar/dispatch.asl \
	asl/dispatch.asl

ASL_SOURCES := $(ASL_SOURCES_BEFORE_DECODER) $(ASL_SOURCES_AFTER_DECODER)

# Executable semantic test library, assembled after the specification.
ASL_TEST_LIB := \
	tests/asl/state-tests.asl \
	tests/asl/bundle-tests.asl \
	tests/asl/postprocess-tests.asl \
	tests/asl/scalar-tests.asl \
	tests/asl/tile-tests.asl \
	tests/asl/tepl-totality-tests.asl \
	tests/asl/tlsu-totality-tests.asl \
	tests/asl/cube-totality-tests.asl \
	tests/asl/dispatch-tests.asl \
	tests/asl/concurrency-tests.asl \
	tests/asl/profile-tests.asl \
	tests/asl/numeric/formats/common.asl \
	tests/asl/numeric/formats/fp64.asl \
	tests/asl/numeric/formats/fp32.asl \
	tests/asl/numeric/formats/tf32.asl \
	tests/asl/numeric/formats/hf32.asl \
	tests/asl/numeric/formats/fp16.asl \
	tests/asl/numeric/formats/bf16.asl \
	tests/asl/numeric/formats/e4m3.asl \
	tests/asl/numeric/formats/e5m2.asl \
	tests/asl/numeric/formats/e3m2.asl \
	tests/asl/numeric/formats/e2m3.asl \
	tests/asl/numeric/formats/hif8.asl \
	tests/asl/numeric/formats/e2m1x2.asl \
	tests/asl/numeric/formats/e1m2x2.asl \
	tests/asl/numeric/formats/hif4x2.asl \
	tests/asl/numeric/formats/e8m0.asl

ASL_TEST_MAIN := tests/asl/main.asl
ASL_TESTS := $(ASL_TEST_LIB) $(ASL_TEST_MAIN)

# Shards partition every call in the canonical main exactly once. The
# repository checker rejects missing or duplicate calls before ASLRef runs.
ASL_TEST_SHARD_MAINS := \
	tests/asl/shards/scalar-agu-totality.asl \
	tests/asl/shards/scalar-agu-aliases.asl \
	tests/asl/shards/scalar-fsu-totality.asl \
	tests/asl/shards/scalar-sys-transfers.asl \
	tests/asl/shards/scalar-sys-transfers-256-511.asl \
	tests/asl/shards/scalar-sys-transfers-512-767.asl \
	tests/asl/shards/scalar-sys-transfers-768-1023.asl \
	tests/asl/shards/scalar-sys-transfers-1024-1279.asl \
	tests/asl/shards/scalar-sys-transfers-1280-1535.asl \
	tests/asl/shards/scalar-sys-transfers-1536-1791.asl \
	tests/asl/shards/scalar-sys-transfers-1792-1936.asl \
	tests/asl/shards/scalar-sys-aliases.asl \
	tests/asl/shards/scalar-sys-swap-aliases-0-7.asl \
	tests/asl/shards/scalar-sys-swap-aliases-8-15.asl \
	tests/asl/shards/scalar-sys-swap-aliases-16-23.asl \
	tests/asl/shards/scalar-sys-swap-aliases-24-31.asl \
	tests/asl/shards/scalar-sys-fences.asl \
	tests/asl/shards/scalar-sys-traps.asl \
	tests/asl/shards/scalar-sys-requests.asl \
	tests/asl/shards/scalar-sys-maintenance-selectors.asl \
	tests/asl/shards/scalar-sys-maintenance-legality.asl \
	tests/asl/shards/tepl-totality.asl \
	tests/asl/shards/tlsu-totality.asl \
	tests/asl/shards/cube-totality.asl \
	tests/asl/shards/core-bundle.asl \
	tests/asl/shards/postprocess.asl \
	tests/asl/shards/scalar-base.asl \
	tests/asl/shards/scalar-agu-effects.asl \
	tests/asl/shards/scalar-alu-bru.asl \
	tests/asl/shards/scalar-amo.asl \
	tests/asl/shards/scalar-fsu.asl \
	tests/asl/shards/scalar-sys.asl \
	tests/asl/shards/tile-ops.asl \
	tests/asl/shards/tile-lifecycle.asl \
	tests/asl/shards/concurrency-profile.asl \
	tests/asl/shards/numeric-formats.asl

ASL_TEST_SHARD_NAMES := $(patsubst tests/asl/shards/%.asl,%,$(ASL_TEST_SHARD_MAINS))
ASL_TEST_SHARD_SPECS := $(addprefix build/pto-tests-,$(addsuffix .asl,$(ASL_TEST_SHARD_NAMES)))
ASL_TEST_SHARD_TARGETS := $(addprefix test-shard-,$(ASL_TEST_SHARD_NAMES))
ASL_TEST_JOBS ?= 4

# Each runtime shard includes only the test libraries that define its calls.
# The canonical full-suite assembly below remains the exact whole-library gate.
ASL_TEST_LIB_core-bundle := \
	tests/asl/state-tests.asl \
	tests/asl/bundle-tests.asl \
	tests/asl/dispatch-tests.asl
ASL_TEST_LIB_postprocess := tests/asl/postprocess-tests.asl
ASL_TEST_LIB_scalar-base := tests/asl/scalar-tests.asl
ASL_TEST_LIB_scalar-agu-effects := tests/asl/scalar-tests.asl
ASL_TEST_LIB_scalar-agu-totality := tests/asl/scalar-tests.asl
ASL_TEST_LIB_scalar-agu-aliases := tests/asl/scalar-tests.asl
ASL_TEST_LIB_scalar-alu-bru := tests/asl/scalar-tests.asl
ASL_TEST_LIB_scalar-amo := tests/asl/scalar-tests.asl
ASL_TEST_LIB_scalar-fsu := tests/asl/scalar-tests.asl
ASL_TEST_LIB_scalar-fsu-totality := tests/asl/scalar-tests.asl
ASL_TEST_LIB_scalar-sys := tests/asl/scalar-tests.asl
ASL_TEST_LIB_scalar-sys-transfers := tests/asl/scalar-tests.asl
ASL_TEST_LIB_scalar-sys-transfers-256-511 := tests/asl/scalar-tests.asl
ASL_TEST_LIB_scalar-sys-transfers-512-767 := tests/asl/scalar-tests.asl
ASL_TEST_LIB_scalar-sys-transfers-768-1023 := tests/asl/scalar-tests.asl
ASL_TEST_LIB_scalar-sys-transfers-1024-1279 := tests/asl/scalar-tests.asl
ASL_TEST_LIB_scalar-sys-transfers-1280-1535 := tests/asl/scalar-tests.asl
ASL_TEST_LIB_scalar-sys-transfers-1536-1791 := tests/asl/scalar-tests.asl
ASL_TEST_LIB_scalar-sys-transfers-1792-1936 := tests/asl/scalar-tests.asl
ASL_TEST_LIB_scalar-sys-aliases := tests/asl/scalar-tests.asl
ASL_TEST_LIB_scalar-sys-swap-aliases-0-7 := tests/asl/scalar-tests.asl
ASL_TEST_LIB_scalar-sys-swap-aliases-8-15 := tests/asl/scalar-tests.asl
ASL_TEST_LIB_scalar-sys-swap-aliases-16-23 := tests/asl/scalar-tests.asl
ASL_TEST_LIB_scalar-sys-swap-aliases-24-31 := tests/asl/scalar-tests.asl
ASL_TEST_LIB_scalar-sys-fences := tests/asl/scalar-tests.asl
ASL_TEST_LIB_scalar-sys-traps := tests/asl/scalar-tests.asl
ASL_TEST_LIB_scalar-sys-requests := tests/asl/scalar-tests.asl
ASL_TEST_LIB_scalar-sys-maintenance-selectors := tests/asl/scalar-tests.asl
ASL_TEST_LIB_scalar-sys-maintenance-legality := tests/asl/scalar-tests.asl
ASL_TEST_LIB_tile-ops := tests/asl/tile-tests.asl
ASL_TEST_LIB_tile-lifecycle := tests/asl/tile-tests.asl
ASL_TEST_LIB_tepl-totality := tests/asl/tepl-totality-tests.asl
ASL_TEST_LIB_tlsu-totality := tests/asl/tlsu-totality-tests.asl
ASL_TEST_LIB_cube-totality := tests/asl/cube-totality-tests.asl
ASL_TEST_LIB_concurrency-profile := \
	tests/asl/concurrency-tests.asl \
	tests/asl/profile-tests.asl
ASL_TEST_LIB_numeric-formats := \
	tests/asl/numeric/formats/common.asl \
	tests/asl/numeric/formats/fp64.asl \
	tests/asl/numeric/formats/fp32.asl \
	tests/asl/numeric/formats/tf32.asl \
	tests/asl/numeric/formats/hf32.asl \
	tests/asl/numeric/formats/fp16.asl \
	tests/asl/numeric/formats/bf16.asl \
	tests/asl/numeric/formats/e4m3.asl \
	tests/asl/numeric/formats/e5m2.asl \
	tests/asl/numeric/formats/e3m2.asl \
	tests/asl/numeric/formats/e2m3.asl \
	tests/asl/numeric/formats/hif8.asl \
	tests/asl/numeric/formats/e2m1x2.asl \
	tests/asl/numeric/formats/e1m2x2.asl \
	tests/asl/numeric/formats/hif4x2.asl \
	tests/asl/numeric/formats/e8m0.asl

SPEC := build/pto-spec.asl
DECODER_SPEC := build/decoders.asl
TEST_SPEC := build/pto-tests.asl

.PHONY: all setup build release-manifest release-check release-validate repo-check \
	toolchain-check check test test-parallel test-shards \
	$(ASL_TEST_SHARD_TARGETS) ci clean print-asl-sources \
	print-asl-tests print-asl-test-shards

all: ci

setup:
	./scripts/setup-aslref

build: $(SPEC)

$(DECODER_SPEC): scripts/generate-asl-decoders spec/catalog/scalar-forms.json \
		spec/catalog/command-forms.json \
		spec/catalog/numeric-profile-applicability.json \
		spec/catalog/system-registers.json spec/catalog/tile-operations.json
	@mkdir -p build
	@./scripts/generate-asl-decoders > $@

$(SPEC): $(ASL_SOURCES) $(DECODER_SPEC) scripts/assemble-asl Makefile
	./scripts/assemble-asl $@ $(ASL_SOURCES_BEFORE_DECODER) $(DECODER_SPEC) $(ASL_SOURCES_AFTER_DECODER)

$(TEST_SPEC): $(SPEC) $(ASL_TESTS) scripts/assemble-asl Makefile
	./scripts/assemble-asl $@ $(SPEC) $(ASL_TESTS)

release-manifest:
	./scripts/generate-release-manifest

release-check:
	./scripts/check-release-manifest
	./scripts/check-binary-closure

release-validate:
	./scripts/validate-release

.SECONDEXPANSION:
build/pto-tests-%.asl: $(SPEC) $$(ASL_TEST_LIB_$$*) tests/asl/shards/%.asl \
		scripts/assemble-asl Makefile
	./scripts/assemble-asl $@ $(SPEC) $(ASL_TEST_LIB_$*) tests/asl/shards/$*.asl

repo-check: $(SPEC)
	./scripts/check-repository
	./scripts/check-asl-test-shards
	./scripts/check-binary-closure

# Canary checks proving the pinned ASLRef distinguishes valid from invalid ASL1.
toolchain-check:
	ASLREF="$(ASLREF)" ./scripts/check-toolchain

check: $(SPEC)
	$(ASLREF) --type-check-strict --no-exec $(SPEC)

test: $(TEST_SPEC)
	$(ASLREF) --type-check-strict $(TEST_SPEC)

$(ASL_TEST_SHARD_TARGETS): test-shard-%: build/pto-tests-%.asl
	$(ASLREF) --type-check-strict $<

test-shards: $(ASL_TEST_SHARD_TARGETS)

test-parallel: $(ASL_TEST_SHARD_SPECS)
	$(MAKE) --no-print-directory -j$(ASL_TEST_JOBS) test-shards

ci: repo-check toolchain-check check test-parallel

print-asl-sources:
	@printf '%s\n' $(ASL_SOURCES)

print-asl-tests:
	@printf '%s\n' $(ASL_TESTS)

print-asl-test-shards:
	@printf '%s\n' $(ASL_TEST_SHARD_MAINS)

clean:
	rm -rf build
