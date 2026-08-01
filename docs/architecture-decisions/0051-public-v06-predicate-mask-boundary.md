# ADR 0051: Reconcile the public v0.6 typed-mask surface without changing PTO ISA 0.57.1

- Status: accepted
- Decision date: 2026-08-01
- Requirements: PTO-REQ-PREDICATE-001, PTO-REQ-CLOSURE-001,
  PTO-REQ-RELEASE-ISA-001
- Tracks: issue #28

## Context

PTO ISA 0.57.1 has two distinct predicate-related architectural state domains:

- P0 through P7 are eight 32-bit per-warp predicate registers. P0 is
  hardwired to all ones; P1 through P7 reset to zero; all eight are preserved
  independently across traps. No accepted 0.57.1 instruction produces or
  consumes this register file.
- MPAR and MSEQ bodies use one separate 64-bit execution mask. Machine-body
  entry initializes it to all ones, and `B.Z` and `B.NZ` consume it while such
  a body is active.

The public PTO repository has advanced to a v0.6 micro-instruction surface.
Its source language documents first-class `!pto.mask<G>` values with logical
widths of 64, 128, or 256 bits according to the active element granularity.
Public `pto.p*` operations generate and combine these values, predicate
load/store operations transfer them, and public `pto.v*` operations consume
them. The public micro-instruction reference classifies that surface as an
A5-oriented profile and distinguishes it from the tile-level ISA.

The previous public-source ledger was pinned to commit
`712cbe9f23df5d5362be5e8327599f4285317473`. Issue #28 observed the new mask
surface at `8e2f0fa10ddc1e887ac2e102666854247aee9b77`. The current public `main` used
for this decision is the later exact commit
`1f61a9a28b375e5113761defdc66fd03554b5e0d`; all required pages exist there
and are recorded by content hash.

These three representations use related terminology but do not establish a
shared physical register file, encoding, or width.

## Decision

The public v0.6 `!pto.mask<G>` surface is **outside the active PTO ISA 0.57.1
release line**. This decision does not create a 0.57.1 extension namespace,
profile, decoder, or semantic hook.

The following concepts remain explicitly distinct:

| Concept | Active scope | Width | Producers and consumers | Mapping disposition |
| --- | --- | ---: | --- | --- |
| P0-P7 warp predicates | PTO ISA 0.57.1 | eight × 32 bits | none in accepted 0.57.1 encodings | closed state contract; no instruction mapping |
| MPAR/MSEQ execution mask | PTO ISA 0.57.1 | one × 64 bits | machine-body entry; `B.Z`/`B.NZ` | distinct from P0-P7 |
| `!pto.mask<G>` typed values | public v0.6 micro-instruction layer | 64/128/256 bits | public `pto.p*`, `pto.pld*`, `pto.pst*`, and `pto.v*` source operations | outside 0.57.1 |
| encoded physical predicate-register mapping | future decision | undefined | undefined | must not be inferred |

No public v0.6 type or operation is evidence that P0-P7 changed width. No
`!pto.mask<G>` value is mapped to P0-P7, the MPAR/MSEQ execution mask, a
reserved selector, or any 0.57.1 encoding. A future formal version must assign
its own release or extension identity and define physical-register mapping,
encodings, producer/consumer effects, reset, trap behavior, and executable
evidence before such a mapping is accepted.

The generated public-source ledger advances to the current public commit and
records exact source classes, hashes, pin history, and the four-way concept
matrix. The numeric decision-input ledger remains at its independently audited
older commit because two numeric implementation files changed at the newer
public commit and are not re-audited by this predicate-only decision. Different
evidence purposes may use different exact pins; each pin remains explicit and
content-addressed.

## Consequences

- ADR 0046 and every 0.57.1 ASL state, width, trap, branch, decoder, and
  instruction-semantic rule remain unchanged.
- Stage `S2-T4` remains closed, now with an explicit current-public-version
  reconciliation rather than an implicit vector-surface exclusion.
- Public source evolution cannot silently broaden the formal claim: commit,
  path, content hash, source class, release disposition, and absence of a
  physical mapping are checked exactly.
- Importing the v0.6 micro-instruction surface requires a separate accepted
  architecture change; source-language similarity alone is insufficient.

## Verification

`scripts/generate-public-source-reconciliation --check` proves deterministic
evidence generation. `scripts/check-catalogs` checks the current pin, all ten
source hashes and source classes, the release-line disposition, exact P0-P7 and
execution-mask contracts, v0.6 typed-mask widths and consumers, and the
undefined future physical mapping. Repository and release checks ensure the
decision, requirements, coverage, maturity, and generated release projections
remain synchronized.
