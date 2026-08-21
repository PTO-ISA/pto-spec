# Version-neutral architecture integration

## Status

Approved for implementation.

## Objective

Architecture changes define instruction encoding and behavior without assigning
a release version. A later consolidated release change owns the architecture
version, encoding-ABI identity, release manifest, and release evidence.

## Authority boundary

ASL remains the sole formal architecture source. The binder change defines the
`SizeCode` and `PEMode` fields, their legal values, decoded PE masks, capacity
rules, strict no-effect behavior, and pre-effect rejection points. Generated
instruction pages, catalogs, and independent tests mirror or verify that ASL.

Architecture decision records describe only those semantic and encoding rules.
They do not name a release, predict a future version, or make publication order
part of the ISA contract.

The `[release]` section of `specification.toml`, the release-manifest generator,
the checked-in release manifest, and version-specific release evidence describe
the last published release. An architecture PR does not modify or relabel them.

## Repository checks

Ordinary PR and repository checks validate the current development architecture:

- ASL layout, dependency closure, and strict source mirroring;
- instruction documentation and catalog projections;
- independent mnemonic-named ASL tests and script tests;
- current encoded-form count and an unversioned architecture fingerprint;
- publication hygiene and workflow contracts.

Release-only checks additionally validate version metadata, encoding-ABI
identity, release-manifest freshness, exact-head evidence, and publication
artifacts. They remain fail-closed and are not weakened or treated as passing
before the consolidated release change updates those owned files.

## Implementation shape

The change will:

1. retain the accepted B.IOT/B.IOS ASL, documentation, catalog, and test delta;
2. remove release-version and publication-sequencing language from the active
   architecture decision and PR description;
3. restore release-owned files and release-identity tests to the current
   published state;
4. split development binary closure from release-manifest closure so ordinary
   repository checks do not rewrite a published release identity;
5. keep release-manifest and exact-release checks exclusively in release-only
   targets; and
6. add regressions proving an architecture PR cannot silently change release
   identity and a release cannot proceed with stale architecture evidence.

## Failure behavior

Reserved `SizeCode` values, unsupported PE selections, malformed roles, and
capacity overflow reject before allocation, descriptor, memory, consumption,
or lifetime effects. A zero PE mode remains a strict no-effect path only for an
otherwise accepted encoding. Removing release wording does not change these
architectural behaviors.

## Verification

The implementation must pass targeted binder tests followed by the complete
ordinary PR and repository checks. It must prove release-owned files are
unchanged relative to the PR base. No release workflow, release target, tag, or
publication action is part of this change.

## Out of scope

This change does not choose the next release version, update downstream
toolchains, publish release evidence, or provide backward binary compatibility.
Those actions belong to the later consolidated release workflow.
