# AGENTS.md - PTO Formal Specification

## Purpose

This repository is the normative draft ASL1 specification of the PTO Instruction
Set Architecture. Do not infer or add instruction semantics without an explicit
architecture requirement.

## Working rules

- Read and follow `.codex/skills/pto-asl/SKILL.md` for ASL, formal-review, and governance work.
- Use ASL1 syntax accepted by the commit pinned in `.aslref-version`.
- Keep the architecture entry point under `asl/` and place scalar and tile
  instruction-family sources under `asl/scalar/` and `asl/tile/`.
- Keep `specification.toml`, `spec/requirements.json`, canonical catalogs, evidence manifests,
  coverage, and traceability consistent with every normative change.
- Preserve the one-level architecture: never add nested instruction bodies,
  body-local register files, implicit body queues, or body replay state.
- Do not guess missing preconditions or fault behavior; record an architecture decision gap.
- Treat fixed array bounds as model bounds, not claims about every implementation.
- Add executable tests when concrete instruction or state-transition semantics are introduced.
- Preserve exact mask/match, operand-piece, signedness, constraint, selector,
  decoder-witness, and semantic-handler coverage for every accepted operation.
- Do not encode A2/A3, A5, or CPU implementation behavior as portable PTO semantics without a named target profile.
- Keep toolchain, governance, normative semantics, and mechanical refactors in separate changes.

## Verification

```bash
make repo-check              # no opam switch required
make setup                   # once, to build the pinned ASLRef
make ci
git diff --check
```

Generated `build/` and `.cache/` files must remain untracked.

Do not weaken a check to make a change pass. Catalog witnesses and
`tests/canary/` prove that validation can reject invalid inputs; a failing
fixture is evidence, not an obstacle.
