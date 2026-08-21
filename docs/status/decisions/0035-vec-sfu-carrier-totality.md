---
{
  "id": "ADR-0035",
  "title": "VEC/SFU carrier totality and profile boundary",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "created": "2026-07-31",
  "accepted": "2026-07-31",
  "rejected": null,
  "superseded": null,
  "baseline": "8054a21fc7f98318f936b1dff9d2132b2aa990be",
  "target_releases": [
    "unassigned"
  ],
  "affected_ndf": [
    "PTO-BSTART-SFU-DECISION-BINDING-001",
    "PTO-BSTART-VEC-DECISION-BINDING-001",
    "PTO-TABS-CONTRACT-001",
    "PTO-TADD-CONTRACT-001",
    "PTO-TADDS-CONTRACT-001",
    "PTO-TAND-CONTRACT-001",
    "PTO-TANDS-CONTRACT-001",
    "PTO-TCI-CONTRACT-001",
    "PTO-TCMP-CONTRACT-001",
    "PTO-TCMPS-CONTRACT-001",
    "PTO-TCOLARGMAX-CONTRACT-001",
    "PTO-TCOLARGMIN-CONTRACT-001",
    "PTO-TCOLEXPAND-CONTRACT-001",
    "PTO-TCOLEXPANDADD-CONTRACT-001",
    "PTO-TCOLEXPANDDIV-CONTRACT-001",
    "PTO-TCOLEXPANDEXPDIF-CONTRACT-001",
    "PTO-TCOLEXPANDMAX-CONTRACT-001",
    "PTO-TCOLEXPANDMIN-CONTRACT-001",
    "PTO-TCOLEXPANDMUL-CONTRACT-001",
    "PTO-TCOLEXPANDSUB-CONTRACT-001",
    "PTO-TCOLMAX-CONTRACT-001",
    "PTO-TCOLMIN-CONTRACT-001",
    "PTO-TCOLPROD-CONTRACT-001",
    "PTO-TCOLSUM-CONTRACT-001",
    "PTO-TCONCAT-CONTRACT-001",
    "PTO-TCVT-CONTRACT-001",
    "PTO-TDEQUANT-CONTRACT-001",
    "PTO-TDIV-CONTRACT-001",
    "PTO-TDIVS-CONTRACT-001",
    "PTO-TEXP-CONTRACT-001",
    "PTO-TEXPANDS-CONTRACT-001",
    "PTO-TEXTRACT-CONTRACT-001",
    "PTO-TFILLPAD-CONTRACT-001",
    "PTO-TFMA-CONTRACT-001",
    "PTO-TGATHER-CONTRACT-001",
    "PTO-THISTOGRAM-CONTRACT-001",
    "PTO-TIMG2COL-CONTRACT-001",
    "PTO-TINSERT-CONTRACT-001",
    "PTO-TLOG-CONTRACT-001",
    "PTO-TMAX-CONTRACT-001",
    "PTO-TMAXS-CONTRACT-001",
    "PTO-TMIN-CONTRACT-001",
    "PTO-TMINS-CONTRACT-001",
    "PTO-TMRGSORT-CONTRACT-001",
    "PTO-TMUL-CONTRACT-001",
    "PTO-TMULS-CONTRACT-001",
    "PTO-TNEG-CONTRACT-001",
    "PTO-TNOT-CONTRACT-001",
    "PTO-TOR-CONTRACT-001",
    "PTO-TORS-CONTRACT-001",
    "PTO-TPARTADD-CONTRACT-001",
    "PTO-TPARTMAX-CONTRACT-001",
    "PTO-TPARTMIN-CONTRACT-001",
    "PTO-TPARTMUL-CONTRACT-001",
    "PTO-TQUANT-CONTRACT-001",
    "PTO-TRECIP-CONTRACT-001",
    "PTO-TRELU-CONTRACT-001",
    "PTO-TREM-CONTRACT-001",
    "PTO-TREMS-CONTRACT-001",
    "PTO-TROWARGMAX-CONTRACT-001",
    "PTO-TROWARGMIN-CONTRACT-001",
    "PTO-TROWEXPAND-CONTRACT-001",
    "PTO-TROWEXPANDADD-CONTRACT-001",
    "PTO-TROWEXPANDDIV-CONTRACT-001",
    "PTO-TROWEXPANDEXPDIF-CONTRACT-001",
    "PTO-TROWEXPANDMAX-CONTRACT-001",
    "PTO-TROWEXPANDMIN-CONTRACT-001",
    "PTO-TROWEXPANDMUL-CONTRACT-001",
    "PTO-TROWEXPANDSUB-CONTRACT-001",
    "PTO-TROWMAX-CONTRACT-001",
    "PTO-TROWMIN-CONTRACT-001",
    "PTO-TROWPROD-CONTRACT-001",
    "PTO-TROWSUM-CONTRACT-001",
    "PTO-TRSQRT-CONTRACT-001",
    "PTO-TSCATTER-CONTRACT-001",
    "PTO-TSEL-CONTRACT-001",
    "PTO-TSELS-CONTRACT-001",
    "PTO-TSHL-CONTRACT-001",
    "PTO-TSHLS-CONTRACT-001",
    "PTO-TSHR-CONTRACT-001",
    "PTO-TSHRS-CONTRACT-001",
    "PTO-TSORT-CONTRACT-001",
    "PTO-TSQRT-CONTRACT-001",
    "PTO-TSUB-CONTRACT-001",
    "PTO-TSUBS-CONTRACT-001",
    "PTO-TTRANS-CONTRACT-001",
    "PTO-TTRI-CONTRACT-001",
    "PTO-TXOR-CONTRACT-001",
    "PTO-TXORS-CONTRACT-001"
  ],
  "affected_units": [
    "PTO-BLOCK-BSTART-SFU",
    "PTO-BLOCK-BSTART-VEC",
    "PTO-TILE-TABS",
    "PTO-TILE-TADD",
    "PTO-TILE-TADDS",
    "PTO-TILE-TAND",
    "PTO-TILE-TANDS",
    "PTO-TILE-TCI",
    "PTO-TILE-TCMP",
    "PTO-TILE-TCMPS",
    "PTO-TILE-TCOLARGMAX",
    "PTO-TILE-TCOLARGMIN",
    "PTO-TILE-TCOLEXPAND",
    "PTO-TILE-TCOLEXPANDADD",
    "PTO-TILE-TCOLEXPANDDIV",
    "PTO-TILE-TCOLEXPANDEXPDIF",
    "PTO-TILE-TCOLEXPANDMAX",
    "PTO-TILE-TCOLEXPANDMIN",
    "PTO-TILE-TCOLEXPANDMUL",
    "PTO-TILE-TCOLEXPANDSUB",
    "PTO-TILE-TCOLMAX",
    "PTO-TILE-TCOLMIN",
    "PTO-TILE-TCOLPROD",
    "PTO-TILE-TCOLSUM",
    "PTO-TILE-TCONCAT",
    "PTO-TILE-TCVT",
    "PTO-TILE-TDEQUANT",
    "PTO-TILE-TDIV",
    "PTO-TILE-TDIVS",
    "PTO-TILE-TEXP",
    "PTO-TILE-TEXPANDS",
    "PTO-TILE-TEXTRACT",
    "PTO-TILE-TFILLPAD",
    "PTO-TILE-TFMA",
    "PTO-TILE-TGATHER",
    "PTO-TILE-THISTOGRAM",
    "PTO-TILE-TIMG2COL",
    "PTO-TILE-TINSERT",
    "PTO-TILE-TLOG",
    "PTO-TILE-TMAX",
    "PTO-TILE-TMAXS",
    "PTO-TILE-TMIN",
    "PTO-TILE-TMINS",
    "PTO-TILE-TMRGSORT",
    "PTO-TILE-TMUL",
    "PTO-TILE-TMULS",
    "PTO-TILE-TNEG",
    "PTO-TILE-TNOT",
    "PTO-TILE-TOR",
    "PTO-TILE-TORS",
    "PTO-TILE-TPARTADD",
    "PTO-TILE-TPARTMAX",
    "PTO-TILE-TPARTMIN",
    "PTO-TILE-TPARTMUL",
    "PTO-TILE-TQUANT",
    "PTO-TILE-TRECIP",
    "PTO-TILE-TRELU",
    "PTO-TILE-TREM",
    "PTO-TILE-TREMS",
    "PTO-TILE-TROWARGMAX",
    "PTO-TILE-TROWARGMIN",
    "PTO-TILE-TROWEXPAND",
    "PTO-TILE-TROWEXPANDADD",
    "PTO-TILE-TROWEXPANDDIV",
    "PTO-TILE-TROWEXPANDEXPDIF",
    "PTO-TILE-TROWEXPANDMAX",
    "PTO-TILE-TROWEXPANDMIN",
    "PTO-TILE-TROWEXPANDMUL",
    "PTO-TILE-TROWEXPANDSUB",
    "PTO-TILE-TROWMAX",
    "PTO-TILE-TROWMIN",
    "PTO-TILE-TROWPROD",
    "PTO-TILE-TROWSUM",
    "PTO-TILE-TRSQRT",
    "PTO-TILE-TSCATTER",
    "PTO-TILE-TSEL",
    "PTO-TILE-TSELS",
    "PTO-TILE-TSHL",
    "PTO-TILE-TSHLS",
    "PTO-TILE-TSHR",
    "PTO-TILE-TSHRS",
    "PTO-TILE-TSORT",
    "PTO-TILE-TSQRT",
    "PTO-TILE-TSUB",
    "PTO-TILE-TSUBS",
    "PTO-TILE-TTRANS",
    "PTO-TILE-TTRI",
    "PTO-TILE-TXOR",
    "PTO-TILE-TXORS"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": []
}
---
# ADR 0035: VEC/SFU carrier totality and profile boundary

> Historical-evidence note: test paths named below record the evidence used when this ADR was accepted; they are not active architecture or release owners. Current ownership is the four-surface ASL tree, with per-ID AVS coverage projected into `spec/evidence/release-traceability-readiness.json`.

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

- `tests/asl/tile/model/dispatch/top-level/tile-bound-vec-sfu-carrier-totality-001.asl`
- `spec/catalog/tile-operations.json`
- `spec/evidence/release-traceability-readiness.json`
