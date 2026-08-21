# Releases

The working tree is a normative draft. A release is an immutable commit whose
exact-head release validation and reproducible evidence succeeded, followed by
a separate authorized publication action.

## Current identity

`specification.toml` owns the machine-readable architecture version, encoding
ABI, profile, maturity, and pinned toolchain entry points. The generated
[`spec/release-manifest.json`](../../spec/release-manifest.json) binds canonical
content and encoding fingerprints for that identity.

## Evidence entry points

- [`spec/release-inputs.json`](../../spec/release-inputs.json) registers every
  canonical release-evidence input.
- [`spec/release-selection.json`](../../spec/release-selection.json) owns the
  version, baseline, included NDF status, complete draft exclusion, and minimum
  readiness policy; the manifest expands the exact selected ADR and NDF set.
- [Architecture readiness](../../spec/evidence/architecture-readiness.json)
  derives draft, executable, validated, and released lifecycle stages without
  creating a second semantic authority.
- [Release traceability](../../spec/evidence/release-traceability-readiness.json)
  binds the ASL-to-page-to-AVS graph and links its units and NDF clauses to the
  affected readiness subjects.
- [Release-gate readiness](../../spec/evidence/release-gate-readiness.json)
  records gate and execution-topology closure.
- [ADR index](../../spec/evidence/adr-index.json) maps accepted decisions and
  historical identifiers.
- The generated [changelog](../../CHANGELOG.md) groups accepted ADRs by target
  release and affected surface.

These files are projections or evidence. They do not override current ASL/NDF,
and their presence does not prove a hosted run succeeded for a candidate.

## Candidate verification

The release workflow accepts one full lowercase commit SHA, checks out exactly
that commit, reuses the full validation workflow with release authority,
requires exact equality of planned and reported AVS points, regenerates release
evidence, and finishes only when `Release / validate` succeeds. See the
[validation guide](../governance/validation.md) for the complete contract.
