# AGENTS.md - PTO Formal Specification

## Purpose

This repository is an empty ASL1 formal-specification template for PTO. Do not infer or add instruction semantics
without an explicit architecture requirement.

## Working rules

- Use ASL1 syntax accepted by the pinned ASLRef version in `Makefile`.
- Keep the architecture entry point under `asl/` and place instruction-family sources under `asl/instructions/`.
- State preconditions explicitly with `assert` until the project defines architectural fault behavior.
- Treat fixed array bounds as model bounds, not claims about every implementation.
- Add executable tests when concrete instruction or state-transition semantics are introduced.
- Do not encode A2/A3, A5, or CPU implementation behavior as portable PTO semantics without a named target profile.

## Verification

```bash
make check
```

`make ci` runs the same local gate used by GitHub Actions.
