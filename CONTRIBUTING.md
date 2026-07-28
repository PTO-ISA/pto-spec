# Contributing

`pto-spec` is currently an implementation-free template. Normative PTO semantics require an approved architecture
change proposal before code is added.

## Before opening a pull request

1. Open a formal-model issue for normative types, state, legality, instruction behavior, ordering, or faults.
2. Cite stable public PTO requirement IDs and source links.
3. Separate ASLRef pin updates, governance changes, normative semantics, and mechanical refactors.
4. Follow the repo-local `$pto-asl` skill under `.codex/skills/pto-asl/` when using Codex.
5. Run `make setup` once, then `make ci` and `git diff --check`.

## Pull requests

Keep changes small and reviewable. Complete the pull request template, disclose known gaps, and do not commit generated
`build/` or `.cache/` content. Normative changes must update `docs/traceability.md` and include executable semantic
evidence appropriate to the change.

Commit messages should explain intent and record important constraints, rejected alternatives, verification, and known
gaps. Use native Git trailers when those details are useful.

## Licensing gate

No project license has been selected. Do not copy third-party specification text or source into this repository.
External semantic contributions cannot be accepted until maintainers approve and add a project license and contribution
terms.
