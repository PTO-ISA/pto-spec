# Scheme A ASL Test Governance Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task by task.

**Goal:** Enforce scheme A: all ASL tests live in the exact mirrored `tests/asl/` hierarchy, use concise structured filenames, explain their purpose, and keep normative ASL implementations readable.

**Architecture:** Extend the existing `scripts/asl_tests.py` ownership validator rather than creating a second policy layer. Extend `scripts/asl_units.py` for the source readability invariant. Make `scripts/generate-mnemonic-avs.py` emit the same canonical names, then perform one deterministic repository-wide rename without retaining legacy aliases.

**Tech Stack:** Python 3 standard library, `unittest`, repository-native ASL metadata, Make-based lightweight gates.

## Global Constraints

- Preserve stable `PTO-TEST.id` values and test contents unless a summary is genuinely non-descriptive.
- Preserve all unrelated dirty worktree changes.
- Do not add a new test root or a parallel manifest.
- Do not retain legacy test filenames, symlinks, or compatibility fallbacks.
- Use failing regression tests before production changes.
- Keep release-scale ASL verification out of the PR path; run only targeted and repository lightweight checks here.

---

### Task 1: Lock the canonical filename and mirror contract

**Files:**
- Modify: `tests/scripts/test_asl_tests.py`
- Modify: `scripts/asl_tests.py`

1. Add tests accepting `<group>-<type>-<name>-<NNN>.asl` when group and type match the owner and metadata.
2. Add tests rejecting historical ID filenames, wrong group, wrong type, forbidden purpose tokens, malformed numbering, and filenames longer than 68 characters.
3. Run `python3 -m unittest tests.scripts.test_asl_tests` and confirm the new cases fail.
4. Add one canonical filename parser and fixed kind-to-type mapping to `scripts/asl_tests.py`.
5. Remove the historical ID and generic short-name fallback.
6. Rerun the targeted test module and confirm it passes.

### Task 2: Lock multiline normative ASL bodies

**Files:**
- Modify: `tests/scripts/test_asl_units.py`
- Modify: `scripts/asl_units.py`

1. Add a fixture with a complete `begin ... end;` body on one line and assert that layout validation rejects it.
2. Confirm the new test fails.
3. Extend `validate_layout` to reject same-line complete implementation bodies in `asl/` units.
4. Confirm the targeted unit tests pass.

### Task 3: Make generated AVS filenames canonical

**Files:**
- Modify: `tests/scripts/test_generate_mnemonic_avs.py`
- Modify: `scripts/generate-mnemonic-avs.py`

1. Add generator regressions for canonical group/type/purpose/sequence filenames.
2. Confirm the new generator test fails.
3. Replace ID-derived generated paths with canonical filename construction.
4. Keep the global ID embedded in `PTO-TEST` metadata unchanged.
5. Confirm generator unit tests pass.

### Task 4: Migrate the complete existing test corpus

**Files:**
- Move: `tests/asl/**/*.asl`

1. Build a deterministic rename map from owner group, metadata kind, concise existing purpose, and stable numeric suffix.
2. Reject collisions, invalid owner mirrors, overlength outputs, and forbidden tokens before moving any file.
3. Rename all test files in one mechanical migration; do not leave duplicates or aliases.
4. Run `./scripts/check-asl-tests --list` to prove the full corpus is discoverable under the new contract.

### Task 5: Publish governance and keep projections current

**Files:**
- Modify: `CONTRIBUTING.md`
- Modify: `GOVERNANCE.md`
- Modify: repository navigation or generated evidence only where repository generators require it

1. Document the exact test location, filename grammar, kind mapping, summary/pass-condition requirement, and multiline ASL rule.
2. Regenerate mnemonic AVS and documentation projections with repository-native generators.
3. Refresh lightweight release evidence only when its registered inputs changed.

### Task 6: Verify the governance closure

1. Run targeted Python unit tests for ASL units, ASL tests, and mnemonic AVS generation.
2. Run `./scripts/check-asl-layout` and `./scripts/check-asl-tests --list`.
3. Run `make pr-check`.
4. Run `git diff --check`.
5. Report exact passing counts and any release-scale validation intentionally not run.
