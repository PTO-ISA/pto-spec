ASLREF ?= ./scripts/aslref

# Checked-in specification sources, in dependency order around the generated
# decoder declarations.
ASL_SOURCES_BEFORE_DECODER := \
	asl/arch/overview/architecture.asl \
	asl/arch/programming-model/core-pe-topology.asl \
	asl/arch/features/tile-allocation.asl \
	asl/arch/data-types/integer.asl \
	asl/arch/data-types/fault.asl \
	asl/block/model/state/types.asl \
	asl/arch/data-types/memory-model.asl \
	asl/arch/data-types/memory-operations.asl \
	asl/arch/data-types/system-registers.asl \
	asl/arch/data-types/floating-point.asl \
	asl/arch/data-types/rounding.asl \
	asl/arch/data-types/numeric-classification.asl \
	asl/arch/features/mx-formats.asl \
	asl/arch/data-types/tile-data-types.asl \
	asl/arch/data-types/packed.asl \
	asl/arch/overview/instruction-classification.asl \
	asl/scalar/model/types/operations.asl \
	asl/tile/model/state/types.asl \
	asl/arch/data-types/trap-context.asl \
	asl/arch/system-registers/addressing.asl \
	asl/arch/programming-model/execution-context.asl \
	asl/arch/system-registers/access-control.asl \
	asl/arch/system-registers/context.asl \
	asl/arch/system-registers/timer.asl \
	asl/arch/system-registers/interrupt.asl \
	asl/arch/programming-model/scalar-registers.asl \
	asl/arch/state/program-counter.asl \
	asl/arch/state/execution-mask.asl \
	asl/arch/programming-model/predicate-registers.asl \
	asl/arch/features/predication.asl \
	asl/arch/programming-model/tile-registers.asl \
	asl/arch/programming-model/shared-tile-registers.asl \
	asl/arch/features/shared-tile-state.asl \
	asl/arch/state/tile-descriptor.asl \
	asl/arch/state/definedness.asl \
	asl/arch/state/trap-context.asl \
	asl/arch/memory-model/fault-precision.asl \
	asl/arch/memory-model/address-space.asl \
	asl/block/model/state/control-state.asl \
	asl/block/model/state/descriptor-state.asl \
	asl/block/model/state/binding-state.asl \
	asl/block/model/lifecycle/reset.asl \
	asl/block/model/schema/dimensions.asl \
	asl/block/model/operands/shared-bindings.asl \
	asl/block/model/operands/scalar-bindings.asl \
	asl/block/model/operands/tile-bindings.asl \
	asl/block/model/schema/header.asl \
	asl/block/model/schema/attributes.asl \
	asl/block/model/lifecycle/begin.asl \
	asl/block/model/lifecycle/enter-stop.asl \
	asl/block/model/lifecycle/lifetime.asl \
	asl/block/model/commit/effects.asl \
	asl/tile/state.asl \
	asl/scalar/model/types/operands.asl \
	asl/scalar/model/alu/semantics.asl \
	asl/scalar/model/bru/semantics.asl \
	asl/scalar/model/agu/memory.asl \
	asl/arch/memory-model/memory-events.asl \
	asl/arch/memory-model/atomicity.asl \
	asl/arch/memory-model/ordering.asl \
	asl/scalar/model/agu/addressing.asl \
	asl/scalar/model/amo/semantics.asl \
	asl/scalar/model/sys/semantics.asl \
	asl/scalar/model/sys/registers.asl \
	asl/arch/system-registers/maintenance.asl \
	asl/scalar/model/fsu/arithmetic.asl \
	asl/scalar/model/fsu/profile.asl \
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

ASL_MNEMONIC_SOURCES := $(sort $(wildcard \
	asl/scalar/*/*.asl \
	asl/block/*/*.asl \
	asl/tile/*/*/*.asl))

ASL_SOURCES_AFTER_DECODER := \
	asl/arch/profile/reset.asl \
	asl/arch/profile/applicability.asl \
	asl/arch/profile/reference-profile.asl \
	asl/block/model/schema/profile-encoding.asl \
	$(ASL_MNEMONIC_SOURCES) \
	asl/block/model/dispatch/decode.asl \
	asl/block/model/dispatch/descriptor-legality.asl \
	asl/block/model/dispatch/scalar-schema.asl \
	asl/block/model/dispatch/tile-schema.asl \
	asl/block/model/dispatch/numeric-control.asl \
	asl/block/model/dispatch/destination-shape.asl \
	asl/block/model/faults/rollback.asl \
	asl/block/model/dispatch/shared-cube.asl \
	asl/block/model/dispatch/shared-tlsu.asl \
	asl/block/model/dispatch/tile-execution.asl \
	asl/block/model/commit/validation.asl \
	asl/block/model/dispatch/start.asl \
	asl/block/model/dispatch/commands.asl \
	asl/block/model/dispatch/top-level.asl \
	asl/scalar/model/dispatch/decode.asl \
	asl/scalar/model/dispatch/alu.asl \
	asl/scalar/model/dispatch/bru.asl \
	asl/scalar/model/dispatch/sys.asl \
	asl/scalar/model/dispatch/amo.asl \
	asl/scalar/model/dispatch/agu.asl \
	asl/scalar/model/dispatch/fsu.asl \
	asl/scalar/model/dispatch/top-level.asl \
	asl/arch/dispatch/top-level.asl

ASL_SOURCES := $(ASL_SOURCES_BEFORE_DECODER) $(ASL_SOURCES_AFTER_DECODER)

# Executable semantic test library, assembled after the specification.
ASL_TEST_LIB := \
	tests/asl/state-tests.asl \
	tests/asl/bundle-tests.asl \
	tests/asl/scalar-tests.asl \
	tests/asl/tile-tests.asl \
	tests/asl/tepl-totality-tests.asl \
	tests/asl/tlsu-totality-tests.asl \
	tests/asl/cube-totality-tests.asl \
	tests/asl/dispatch-tests.asl \
	tests/asl/concurrency-tests.asl \
	tests/asl/profile-tests.asl

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
	tests/asl/shards/bundle-scalar-defaults.asl \
	tests/asl/shards/bundle-tile-allocation.asl \
	tests/asl/shards/scalar-base.asl \
	tests/asl/shards/scalar-agu-effects.asl \
	tests/asl/shards/scalar-alu-bru.asl \
	tests/asl/shards/scalar-amo.asl \
	tests/asl/shards/scalar-fsu.asl \
	tests/asl/shards/scalar-sys.asl \
	tests/asl/shards/tepl-elementwise.asl \
	tests/asl/shards/tload-tstore.asl \
	tests/asl/shards/tmatmul-tgemv.asl \
	tests/asl/shards/cube-numeric-contract.asl \
	tests/asl/shards/cube-accumulator-classes.asl \
	tests/asl/shards/tepl-reduction.asl \
	tests/asl/shards/tepl-expansion.asl \
	tests/asl/shards/tepl-generation.asl \
	tests/asl/shards/tepl-rearrangement.asl \
	tests/asl/shards/tepl-complex.asl \
	tests/asl/shards/tepl-conversion.asl \
	tests/asl/shards/tile-handler-closure.asl \
	tests/asl/shards/mgather-mscatter-cube-extensions.asl \
	tests/asl/shards/tile-dispatch.asl \
	tests/asl/shards/tile-capacity.asl \
	tests/asl/shards/tile-definedness.asl \
	tests/asl/shards/shared-tload-atomic.asl \
	tests/asl/shards/tile-legality.asl \
	tests/asl/shards/mgather-mscatter-restart.asl \
	tests/asl/shards/concurrency-profile.asl

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
ASL_TEST_LIB_bundle-scalar-defaults := tests/asl/bundle-tests.asl
ASL_TEST_LIB_bundle-tile-allocation := tests/asl/bundle-tests.asl
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
ASL_TEST_LIB_tepl-elementwise := tests/asl/tile-tests.asl
ASL_TEST_LIB_tload-tstore := tests/asl/tile-tests.asl
ASL_TEST_LIB_tmatmul-tgemv := tests/asl/tile-tests.asl
ASL_TEST_LIB_cube-numeric-contract := tests/asl/tile-tests.asl
ASL_TEST_LIB_cube-accumulator-classes := tests/asl/tile-tests.asl
ASL_TEST_LIB_tepl-reduction := tests/asl/tile-tests.asl
ASL_TEST_LIB_tepl-expansion := tests/asl/tile-tests.asl
ASL_TEST_LIB_tepl-generation := tests/asl/tile-tests.asl
ASL_TEST_LIB_tepl-rearrangement := tests/asl/tile-tests.asl
ASL_TEST_LIB_tepl-complex := tests/asl/tile-tests.asl
ASL_TEST_LIB_tepl-conversion := tests/asl/tile-tests.asl
ASL_TEST_LIB_tile-handler-closure := tests/asl/tile-tests.asl
ASL_TEST_LIB_mgather-mscatter-cube-extensions := tests/asl/tile-tests.asl
ASL_TEST_LIB_tile-dispatch := tests/asl/tile-tests.asl
ASL_TEST_LIB_tile-capacity := tests/asl/tile-tests.asl
ASL_TEST_LIB_tile-definedness := tests/asl/tile-tests.asl
ASL_TEST_LIB_shared-tload-atomic := tests/asl/tile-tests.asl
ASL_TEST_LIB_tile-legality := tests/asl/tile-tests.asl
ASL_TEST_LIB_mgather-mscatter-restart := tests/asl/tile-tests.asl
ASL_TEST_LIB_tepl-totality := tests/asl/tepl-totality-tests.asl
ASL_TEST_LIB_tlsu-totality := tests/asl/tlsu-totality-tests.asl
ASL_TEST_LIB_cube-totality := tests/asl/cube-totality-tests.asl
ASL_TEST_LIB_concurrency-profile := \
	tests/asl/concurrency-tests.asl \
	tests/asl/profile-tests.asl

SPEC := build/pto-spec.asl
DECODER_SPEC := build/decoders.asl
TEST_SPEC := build/pto-tests.asl

.PHONY: all setup build release-manifest release-check release-prepare release-verify repo-check pr-check \
	toolchain-check check test test-parallel test-shards \
	$(ASL_TEST_SHARD_TARGETS) ci clean print-asl-sources \
	print-asl-tests print-asl-test-shards print-asl-test-shard-names

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

.SECONDEXPANSION:
build/pto-tests-%.asl: $(SPEC) $$(ASL_TEST_LIB_$$*) tests/asl/shards/%.asl \
		scripts/assemble-asl Makefile
	./scripts/assemble-asl $@ $(SPEC) $(ASL_TEST_LIB_$*) tests/asl/shards/$*.asl

repo-check: $(SPEC)
	./scripts/check-repository
	./scripts/check-asl-test-shards
	./scripts/check-binary-closure

pr-check:
	./scripts/check-pr

release-verify: pr-check release-check toolchain-check check test-shards

release-prepare:
	./scripts/generate-release-manifest
	./scripts/check-release-manifest
	git diff --exit-code -- spec/release-manifest.json spec/evidence

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

ci: pr-check

print-asl-sources:
	@printf '%s\n' $(ASL_SOURCES)

print-asl-tests:
	@printf '%s\n' $(ASL_TESTS)

print-asl-test-shards:
	@printf '%s\n' $(ASL_TEST_SHARD_MAINS)

print-asl-test-shard-names:
	@printf '%s\n' $(ASL_TEST_SHARD_NAMES)

clean:
	rm -rf build
