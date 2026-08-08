ASLREF ?= ./scripts/aslref
RELEASE_COMMIT ?=

# ASL source order is generated from unit metadata and its dependency graph.
ASL_SOURCE_ORDER := build/asl-source-order.txt
ASL_UNIT_SOURCES := $(shell find asl -type f -name '*.asl' | sort)
SPEC := build/pto-spec.asl
DECODER_SPEC := build/decoders.asl

.PHONY: all setup build clean release-manifest release-evidence-check release-check release-prepare \
	release-verify repo-check pr-check toolchain-check check test test-parallel ci \
	check-asl-layout check-ndf check-asl-tests check-projections \
	check-publication-hygiene print-asl-sources print-asl-tests

all: ci

setup:
	./scripts/setup-aslref

build: $(SPEC)

$(DECODER_SPEC): $(ASL_UNIT_SOURCES) scripts/generate-asl-decoders \
		scripts/project_asl_catalogs.py scripts/asl_units.py \
		spec/catalog/numeric-profile-applicability.json \
		spec/catalog/system-registers.json
	@mkdir -p build
	@./scripts/generate-asl-decoders > $@

$(ASL_SOURCE_ORDER): $(ASL_UNIT_SOURCES) scripts/generate-asl-source-order scripts/asl_units.py
	@mkdir -p build
	./scripts/generate-asl-source-order --root . --output $@

$(SPEC): $(ASL_SOURCE_ORDER) $(DECODER_SPEC) scripts/assemble-asl Makefile
	./scripts/assemble-asl --order $(ASL_SOURCE_ORDER) --decoder $(DECODER_SPEC) --output $@

check-asl-layout:
	./scripts/check-asl-layout

check-ndf:
	./scripts/check-ndf

check-asl-tests:
	./scripts/check-asl-tests

check-projections:
	python3 scripts/project_asl_catalogs.py --root . --check
	python3 scripts/instruction_docs.py --check
	python3 scripts/generate-mnemonic-avs.py --check

check-publication-hygiene:
	python3 scripts/check-publication-hygiene

pr-check: check-asl-layout check-ndf check-asl-tests check-projections check-publication-hygiene
	./scripts/check-release-workflow
	python3 -m unittest discover -s tests/scripts -p 'test_*.py'
	git diff --check

repo-check: $(SPEC)
	./scripts/check-repository
	./scripts/check-binary-closure

release-manifest:
	./scripts/generate-release-manifest

release-evidence-check:
	./scripts/generate-release-traceability-readiness --check
	./scripts/generate-release-gate-readiness --check
	./scripts/check-release-closure
	./scripts/check-binary-closure
	./scripts/check-release-manifest

release-prepare: release-evidence-check
	./scripts/generate-release-manifest
	./scripts/check-release-manifest
	git diff --exit-code -- spec/release-manifest.json spec/evidence

# These commands are intentionally absent from pr-check. They are release-only.
toolchain-check:
	ASLREF="$(ASLREF)" ./scripts/check-toolchain

check: $(SPEC)
	$(ASLREF) --type-check-strict --no-exec $(SPEC)

release-check: pr-check release-evidence-check toolchain-check check
	@test -n "$(RELEASE_COMMIT)" || \
		{ echo 'RELEASE_COMMIT=<exact 40-hex HEAD> is required' >&2; exit 2; }
	./scripts/run-asl-release-suite --commit "$(RELEASE_COMMIT)"

release-verify: release-check

test-parallel:
	$(MAKE) --no-print-directory release-check RELEASE_COMMIT="$$(git rev-parse HEAD)"

test: test-parallel

ci: pr-check

print-asl-sources:
	@cat $(ASL_SOURCE_ORDER)

print-asl-tests:
	@find tests/asl -type f -name '*.asl' | sort

clean:
	rm -rf build
