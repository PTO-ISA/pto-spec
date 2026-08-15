# Governance

## Authority and source order

`specification.toml` records maturity and release identity. Current normative
meaning is owned once, in ASL. Reviewers follow this order:

```text
ASL owner -> generated instruction page -> decision/open metadata -> release evidence
```

Generated Markdown may embed or project ASL but must not reinterpret it.
Accepted architecture decisions explain why a rule exists; they do not replace
the current ASL rule. Git history is the archive, so current trees must not add
legacy copies, backups, or alternate versions.

All architecture changes use stable NDF `PTO-*` clause IDs and the
[Normative Design Framework](https://github.com/hengliao1972/normative_language/blob/main/normative_language.md).
Missing behavior is resolved in the linked issue, not guessed during implementation.

## Two verification lanes

| Lane | Required result | Scope |
| --- | --- | --- |
| Pull request | `PR / validate` | NDF and repository structure, shard topology, generators, script tests, documentation drift, publication hygiene |
| Release candidate | `Release / validate` for one exact 40-character commit SHA | Pinned ASLRef canaries, strict model, every ASL shard, reproducible release evidence |

The PR lane is deliberately fast and does not claim semantic or release
coverage. The release lane is manually dispatched after merge. Pending,
skipped, cancelled, failed, stale, or different-commit jobs never count as
success. The verification workflow does not create a tag or release.

## Enforcement map

| Rule | Enforced by |
| --- | --- |
| NDF regions are unique, well-formed, reference-resolved, and free of legacy copies | `scripts/check-ndf` |
| Instruction pages embed the owning ASL without drift | `scripts/instruction_docs.py --check` |
| ASL tests mirror their owner, use the canonical concise filename grammar, and carry purpose metadata | `scripts/check-asl-tests` |
| Normative ASL implementation bodies remain multiline and reviewable | `scripts/check-asl-layout` |
| PR checks remain lightweight and the release workflow remains exact-head and fail-closed | `scripts/check-pr` and `scripts/check-release-workflow` |
| The pinned ASLRef accepts valid and rejects invalid ASL1 | `scripts/check-toolchain` in the release lane |
| Canonical release evidence is explicitly registered, current, legacy-free, and manifest-complete | `scripts/check-release-closure` in both repository and release lanes |
| Prohibited identities, stale URLs, and broken local documentation links stay unpublished | `scripts/check-publication-hygiene` |
| Review routing for normative, toolchain, and governance paths | `.github/CODEOWNERS` |
| Required checks, signed commits, linear history, resolved conversations, and protected `main` | GitHub repository settings |

GitHub settings are not fully clone-verifiable and must be audited when check
names or ownership change. Administrator privilege may perform an authorized
merge, but it cannot convert an absent or failing required check into success.

## Change classes

- **Normative architecture:** changes state, legality, results, ordering, faults, profiles, encodings, or assembly contracts; requires a linked NDF issue and focused executable evidence.
- **Toolchain:** updates the audited ASLRef pin or build environment; remains isolated from architecture semantics.
- **Governance or projection:** changes workflow, generation, or non-normative explanation without changing ASL meaning.
- **Refactor:** preserves accepted semantics and requires regression evidence.

Catalog changes preserve the machine-readable form or selector, executable
decoder witness, reachable ASL semantic primitive, decoded operand-to-effect
binding, and focused evidence together. A count alone is not closure.

## Review and merge

- Changes land through pull requests after `PR / validate` succeeds for the exact reviewed head.
- Normative PRs link an NDF issue and name changed clause IDs and ASL owners.
- Conversations are resolved before merge; squash merge is preferred for one auditable decision record.
- `main` disallows force pushes and deletion and retains signed, linear history according to repository settings.
- A release candidate is eligible for publication only after `Release / validate` succeeds for that exact merged commit and release artifacts reproduce cleanly.

## Toolchain updates

`.aslref-version` pins a full commit from
`https://github.com/herd/herdtools7.git`. An update must compare upstream parser,
typing, interpreter, standard-library, and conformance-test changes; pass the
complete release lane; update affected canaries; and remain separate from
normative PTO behavior changes.

## Maturity and publication

Maturity transitions update the source hierarchy, status record, NDF clauses,
requirements, executable evidence, coverage, and release manifest together.
At candidate freeze, one immutable commit must have a clean local
`release-verify`/`release-prepare` result and a successful hosted
`Release / validate` result for that same SHA. No earlier branch run, unpinned
approval, or administrator capability substitutes for exact-head evidence.
