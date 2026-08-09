# ADR 0035: VEC/SFU carrier totality and profile boundary

> Historical-evidence note: test paths named below record the evidence used when this ADR was accepted; they are not active architecture or release owners. Current ownership is the four-surface ASL tree, with per-ID AVS coverage projected into `spec/evidence/release-traceability-readiness.json`.

## Status

Accepted.

## Context

`S4-T8` requires every accepted VEC/SFU carrier selector to have a decoded, executable,
pre-effect legality path and a deterministic PTO-v0 reference effect. TEPL also
contains arithmetic and conversion mnemonics whose target numerical behavior is
not yet a closed conformance claim.

The Stage 4 closure therefore needs to separate two questions:

- whether each selector is accepted, reaches one checked handler, rejects
  illegal operands before effects, and has deterministic raw-carrier behavior;
- whether that raw-carrier behavior matches a future hardware or numerical
  profile for floating-point, quantization, rounding, saturation, and
  exceptional values.

Only the first question is closed by this decision. The second remains assigned
to `S5-T2`.

## Decision

PTO-v0 TEPL accepts all 98 catalogued VEC/SFU carrier selectors as raw XLEN-carrier
operations. All 25 architectural `TileDataType` values are legal carriers under
the reference profile. Floating, quantized, rounded, saturated, and exceptional
numeric interpretations remain named profile hooks and are not promoted to
target conformance by this ADR.

Generic TEPL indexing accepts row-major and column-major tile layouts wherever
the operation's shape rule permits them. `TileLayout_ImplementationDefined` is
legal configured state, but generic TEPL operations reject it because the
portable row/column mapping is undefined.

Single-destination TEPL source/destination aliases are legal. Handlers snapshot
source payloads before destination writes, so these aliases have
read-before-write behavior. Same-output aliases on multi-destination TEPL are
rejected:

- `TDEINTERLEAVE` rejects `destination_even == destination_odd`;
- `TPARTARGMAX` and `TPARTARGMIN` reject `destination == destination_indices`.

Partial-region updates preserve existing destination elements outside the
written region. `TINSERT` and `TSCATTER` therefore require the destination
valid region to be defined before the update. Replacement operations define
their destination valid region atomically after writing all selected elements.

Index and ordering corners are fixed as follows:

- `TGATHER` indexes source elements; `TGATHERB` indexes byte offsets aligned to
  the source element width.
- `TSCATTER` applies source elements in source linear order; duplicate
  destination indices are legal and the last write wins.
- `TSORT` is deterministic and stable under the reference ordering helper.
- `TMRGSORT` is stable and left-biased on equal keys.
- `THISTOGRAM` writes cumulative per-row byte histograms. U16 sources may use
  byte 0 or 1; U32 sources may use byte 0 through 3 with the existing
  higher-byte filter rows.
- `TPRELU` is a PTO TEPL extension, not imported from another ISA. PTO-v0 gives
  it raw signed-negative slope multiplication; numerical profile conformance
  remains `S5-T2`.

## Consequences

Stage 4 can evaluate TEPL totality by selector, legality, alias, layout, index,
histogram, sort/merge, and preserved-region evidence without claiming final
target numerical accuracy.

Reviewers must not read the PTO-v0 raw-carrier behavior as an IEEE, hardware,
or accelerator profile. Any future target profile must either preserve these
raw reference results as its debug/portable mode or add explicit profile
overrides and differential conformance evidence.

## Evidence

- `tests/asl/tile/model/dispatch/top-level/PTO-AVS-TILE-TESTVECSFUCARRIERTOTALITY-BOUNDARY-001.asl`
- `spec/evidence/vec-sfu-carrier-totality.json`
