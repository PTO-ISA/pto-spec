# Tests

The test directories cover PTO architecture semantics and the pinned ASLRef
toolchain.

## `asl/`

Executable feature and boundary tests for the normative PTO model. Every file
must be listed in `ASL_TESTS` in the `Makefile`; the ordered sources are
assembled after `build/pto-spec.asl` into `build/pto-tests.asl`.

The final source defines exactly one `main` that returns zero on success.
`scripts/check-repository` rejects an empty test list and rejects listed files
that do not exist.

## `canary/`

Toolchain checks for the pinned ASLRef, exercised by
`make toolchain-check`.

| Fixture | Expected | Asserted diagnostic |
| --- | --- | --- |
| `accept.asl` | strict type-checking succeeds | — |
| `reject-parse.asl` | parsing fails | `ASL Grammar error:` |
| `reject-type.asl` | strict type-checking fails | `ASL Type error:` |
| `exec-pass.asl` | `main` returning zero exits successfully | — |
| `exec-fail.asl` | a run-time failure exits nonzero | `ASL Dynamic error:` |

Rejections are matched against their diagnostic class, not only a nonzero exit.
Otherwise a fixture failing in the wrong phase could satisfy a canary without
testing the intended parser, type-checker, or interpreter behavior.

The expectations are tied to the commit in `.aslref-version`. Update and
explain affected fixtures whenever that pin changes.

See `docs/review-checklist.md` and
`.codex/skills/pto-asl/references/formal-quality.md` for the evidence required
by normative changes.
