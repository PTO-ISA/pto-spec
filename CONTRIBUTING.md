# Contributing

`pto-spec` is an evolving normative architecture repository. ASL is the only
current normative source; generated instruction pages are review projections,
not an independent specification.

## Architecture change flow

1. Open an **NDF architecture change** issue against a full baseline commit.
2. Name every affected stable `PTO-*` clause ID and resolve open questions before implementation.
3. Change the owning ASL clause or mnemonic file first.
4. Regenerate instruction pages, navigation, catalogs, traceability, and evidence owned by that ASL change.
5. Add focused positive, boundary, negative, and state-transition tests.
6. Run `make pr-check` and open a small, reviewable pull request linked to the issue.

Use the NDF clause form and levels defined by the
[Normative Design Framework](https://github.com/hengliao1972/normative_language/blob/main/normative_language.md).
Do not create a parallel prose definition. The lookup order is:

```text
ASL owner -> generated instruction page -> decision/open metadata -> release evidence
```

Defaults, intentionally unspecified behavior, encoding/assembly impact, and
dependent-toolchain impact must be explicit in the issue and represented in
the ASL owner where architectural.

## Pull request lane

`make pr-check` is intentionally lightweight. It checks NDF structure,
repository and shard topology, generators, documentation drift, script tests,
publication hygiene, and whitespace. It does not install opam, run ASLRef, or
claim release readiness.

Keep toolchain changes, governance changes, normative semantics, and mechanical
refactors separate. Do not weaken a canary or validator to make a change pass.

## Release lane

After normative changes are merged, dispatch the `Release verification`
workflow with the exact 40-character `main` commit SHA. The release lane runs
the pinned ASLRef toolchain canaries, strict model, all ASL shards, and
reproducible release evidence. Locally, the equivalent sequential command is:

```bash
make setup
make release-verify
make release-prepare
```

A pending, skipped, failed, stale, or different-commit run is not release
evidence. Verification does not itself create a tag or GitHub release.

## Licensing

Contributions are accepted under the BSD 3-Clause License in `LICENSE`. Do not
copy third-party specification prose, source, or diagrams unless their license
is compatible and attribution is recorded in `NOTICE`.
