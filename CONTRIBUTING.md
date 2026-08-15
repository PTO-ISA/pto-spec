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

## ASL source and test shape

Normative ASL lives only below `asl/arch`, `asl/block`, `asl/scalar`, or
`asl/tile`. A complete `begin ... end;` implementation body must span multiple
physical lines so instruction and architecture behavior remains reviewable.

Executable ASL evidence lives only below `tests/asl/` and mirrors its owner
exactly. For example:

```text
asl/block/operands/B.IOR.asl
tests/asl/block/operands/B.IOR/block-exec-b-ior-ordered-gpr-001.asl
```

Do not add an ad hoc test root or an extra classification directory. Test
filenames use `<group>-<type>-<mnemonic>-<purpose>-<NNN>.asl` for instruction
owners and `<group>-<type>-<purpose>-<NNN>.asl` for architecture concepts
without a mnemonic, where group is
`arch|block|scalar|tile`, `NNN` is `001` through `999`, and the complete
filename is at most 68 characters. The fixed type vocabulary is
`decode|exec|bound|fault|atomic|order|state|static`; it is derived from the
`PTO-TEST.kind` value. Purpose names are lowercase and concise, and must not
contain the redundant tokens `test`, `execution`, `validate`, or `validation`.
The mnemonic component is lowercase, converts punctuation to `-`, and appears
immediately after the type so a filename remains self-identifying outside its
mirror directory (for example, `B.IOR` becomes `b-ior`).

Keep `PTO-TEST.id` stable when renaming a file. The `summary` must state the
behavior under test and `pass_condition` must state the observable success
condition; migration placeholders are not accepted.

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
