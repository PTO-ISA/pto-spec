# AGENTS.md - PTO Formal Specification

## Purpose

This repository is the normative draft ASL1 specification of the PTO Instruction
Set Architecture. Do not infer or add instruction semantics without an explicit
architecture requirement.

## Working rules

- Read and follow `.codex/skills/pto-asl/SKILL.md` for ASL, formal-review, and governance work.
- Current semantics: owning ASL/NDF -> generated mirror -> AVS -> commit-scoped evidence.
- Decision history: ADR index -> affected ASL/NDF. Use
  `spec/evidence/adr-index.json` to locate why and when a rule changed, then
  return to the owning ASL/NDF for current meaning.
- Do not infer semantics from ADR prose, generated catalogs, HTML, spreadsheets,
  changelogs, review summaries, or release projections. Never create a second
  normative explanation.
- Treat mnemonic ASL metadata and its `DOC-BEGIN` regions as the golden source.
  The corresponding Markdown ASL blocks and MkDocs navigation are generated
  projections and MUST pass `python3 scripts/instruction_docs.py --check`.
- Keep hand-written explanation only inside the generated page's supplementary
  region. Never copy normative decode, legality, or operation text into prose.
- Use ASL1 syntax accepted by the commit pinned in `.aslref-version`.
- Keep the architecture entry point under `asl/` and place scalar and tile
  instruction-family sources under `asl/scalar/` and `asl/tile/`.
- Keep `specification.toml`, canonical catalogs, `spec/release-inputs.json`, evidence manifests,
  coverage, and generated release traceability consistent with every normative change.
- Preserve the one-level architecture: never add nested instruction bodies,
  body-local register files, implicit body queues, or body replay state.
- Do not guess missing preconditions or fault behavior; record an architecture decision gap.
- Treat fixed array bounds as model bounds, not claims about every implementation.
- Add executable tests when concrete instruction or state-transition semantics are introduced.
- Keep generated exhaustive matrices at one case per result file. Do not
  restore multi-case shards or use a full-matrix discovery pass for a focused
  rerun; select current IDs with `scripts/print-asl-test-matrix --ids-file`.
- Preserve exact mask/match, operand-piece, signedness, constraint, selector,
  decoder-witness, and semantic-handler coverage for every accepted operation.
- Do not encode A2/A3, A5, or CPU implementation behavior as portable PTO semantics without a named target profile.
- Keep toolchain, governance, normative semantics, and mechanical refactors in separate changes.
- Start normative work from a linked NDF architecture issue naming the baseline
  commit, changed clause IDs, defaults, unspecified behavior, compatibility,
  open questions, focused evidence, and release impact.

## Verification

```bash
make pr-check                # lightweight PR lane; no opam or ASLRef
make repo-check              # generated model and release-evidence closure
git diff --check
```

For focused ASL feedback, write exact IDs to a file, select them with
`scripts/print-asl-test-matrix --ids-file`, and execute the resulting page with
`scripts/run-asl-page -j`. Shared build preparation is sequential; independent
test points are parallel.

Only exact-commit full validation runs the complete model:

```bash
make setup
make release-verify
make release-prepare
```

Generated `build/` and `.cache/` files must remain untracked.

Do not treat a pending, skipped, failed, stale, or different-commit release run
as success. Do not weaken a check to make a change pass. Catalog witnesses and
`tests/canary/` prove that validation can reject invalid inputs; a failing
fixture is evidence, not an obstacle.
