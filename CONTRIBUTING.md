# Contributing

`pto-spec` is a normative draft. Normative PTO semantics require an approved
architecture change proposal before code is added.

## Before opening a pull request

1. Open a formal-model issue for normative types, state, legality, instruction behavior, ordering, or faults.
2. Cite stable public PTO requirement IDs and source links.
3. Separate ASLRef pin updates, governance changes, normative semantics, and mechanical refactors.
4. Follow the repo-local `$pto-asl` skill under `.codex/skills/pto-asl/` when using Codex.
5. Run `make gate-check repo-check` for fast feedback without an opam switch.
6. Run `make setup` once, then `make ci` and `git diff --check`.

## Pull requests

Keep changes small and reviewable. Complete the pull request template, disclose known gaps, and do not commit generated
`build/` or `.cache/` content. Normative changes must update `docs/traceability.md`, add tests under `tests/asl/`,
and list those tests in `ASL_TESTS` so they execute.

Do not relax a check to make a change pass. The fixtures in `tests/` exist to make the checks fail when they stop
working; if one starts failing, explain why in the pull request rather than adjusting it.

For an accepted scalar form, update its exact mask/match, operand pieces,
signedness, constraints, and semantic family together. For a tile operation,
update its selector, handler mapping, evidence disposition, and tests together.
Do not hand-edit `build/decoders.asl`; it is reproduced from the canonical
catalogs during every build.

Commit messages should explain intent and record important constraints, rejected alternatives, verification, and known
gaps. Use native Git trailers when those details are useful.

## Licensing

Contributions are accepted under the BSD 3-Clause License in `LICENSE`. Do not
copy third-party specification prose, source, or diagrams unless their license
is compatible and attribution is recorded in `NOTICE`. Private cross-check
material must never be copied, named, or linked from this repository.
