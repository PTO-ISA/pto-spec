# AGENTS.md - PTO Formal Specification

## Purpose

This repository is an empty ASL1 formal-specification template for PTO. Do not infer or add instruction semantics
without an explicit architecture requirement.

## Working rules

- Read and follow `.codex/skills/pto-asl/SKILL.md` for ASL, formal-review, and governance work.
- Use ASL1 syntax accepted by the commit pinned in `.aslref-version`.
- Keep the architecture entry point under `asl/` and place instruction-family sources under `asl/instructions/`.
- Do not add semantics while `specification.toml` reports template/non-normative status unless the task explicitly
  authorizes the maturity transition and supplies reviewed requirements.
- Do not guess missing preconditions or fault behavior; record an architecture decision gap.
- Treat fixed array bounds as model bounds, not claims about every implementation.
- Add executable tests when concrete instruction or state-transition semantics are introduced.
- Do not encode A2/A3, A5, or CPU implementation behavior as portable PTO semantics without a named target profile.
- Keep toolchain, governance, normative semantics, and mechanical refactors in separate changes.

## Verification

```bash
make setup
make ci
git diff --check
```

Generated `build/` and `.cache/` files must remain untracked.
