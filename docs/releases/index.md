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

The release workflow accepts full lowercase PTO-SPEC, LLVM and ASL-MODEL commit
SHAs. The operator may be an agent acting on an authorized release task. One
frozen tuple is checked before heavy work, then full ASL validation, model
closure and site validation run independently. Evidence aggregation requires
exact equality of planned and reported AVS points. `Release / validate` requires
every gate to succeed for the same tuple. See the
[validation guide](../governance/validation.md) for lane authority and the
[release operations](../../.codex/skills/pto-asl/references/release-operations.md)
for failure handling.

## Prepare publication from hosted evidence

After the exact hosted run completes successfully, an operator agent runs:

```bash
./scripts/prepare-release-publication --run-id RUN_ID --output build/publication-RUN_ID
```

The command uses read-only GitHub access. It verifies the workflow, attempt,
jobs, artifact identities and model evidence, downloads the candidate's assets,
and writes `publication-handoff.json` and `SHA256SUMS`. Its JSON response gives
the next action or a bounded list of blockers. It does not dispatch a workflow,
approve a candidate, create a tag or publish a release.

Publish only under the existing operator authorization, using the validated
commit and assets. Preserve signed tags and enable immutable releases/tag
protection through repository administration before claiming platform-enforced
immutability. Never move a published tag or replace an asset under the same
published identity; issue a new publication revision for a correction.
Keep the manifest, closure evidence and checksums with the permanent release,
rather than relying on expiring Actions artifacts.

Revalidate the hosted run immediately before publication: a local handoff can
be copied or become stale. Once a published release exists,
`--release-tag TAG` can resolve its metadata and emit the existing stable
release-event v1. Publication time and release ID come from the actual release;
an unpublished candidate cannot supply them. The event schema remains compatible
with existing consumers.

Downstream stability and compatibility policy is owned by
[Governance](../../GOVERNANCE.md#compatibility-and-downstream-consumption).
