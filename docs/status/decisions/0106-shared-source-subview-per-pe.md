---
{
  "id": "ADR-0106",
  "title": "Shared source B.SUBVIEW uses per-PE offsets",
  "status": "accepted",
  "authors": ["PTO ISA maintainers"],
  "approvers": ["PTO ISA maintainers"],
  "created": "2026-08-26",
  "accepted": "2026-08-26",
  "rejected": null,
  "superseded": null,
  "baseline": "5114fb699fa510abd9a3c42bcfa5c592cd724961",
  "target_releases": ["0.58.4.1"],
  "affected_ndf": [
    "PTO-B-SUBVIEW-RANGE-001",
    "PTO-B-SUBVIEW-SHARED-PER-PE-001"
  ],
  "affected_units": [
    "PTO-BLOCK-B-SUBVIEW",
    "PTO-BLOCK-MODEL-OPERANDS-SUBVIEW-DESCRIPTOR",
    "PTO-BLOCK-MODEL-OPERANDS-SHARED-GENERATION",
    "PTO-BLOCK-MODEL-DISPATCH-SHARED-TLSU",
    "PTO-BLOCK-MODEL-DISPATCH-SHARED-CUBE-MATRIX"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/159",
  "release_impact": "required",
  "legacy_ids": []
}
---

# ADR 0106: Shared source B.SUBVIEW uses per-PE offsets

## Decision

`B.SUBVIEW` remains a source modifier and does not allocate a new architectural
Tile. For a bound Shared parent, the effective offset for selected PE `i` is
computed from that PE's private GPR plus the encoded unsigned immediate:

```text
OffsetCells[i] = ReadPELocalGPR(i, RegSrc) + ZeroExtend(uimm11)
```

The encoded subview size is common, but selected PEs may derive different ranges
of the same already-published parent. `PE_MASK` selects consumer side effects;
it does not select fixed quarters or imply a common offset.

## Boundary

The parent must already satisfy the whole-parent readiness/publication gate.
Out-of-bounds, misaligned, or schema-incompatible per-PE ranges reject before
payload or memory effects. The same rule applies to TSTORE, Shared-to-Local
TMOV, and Shared-input cooperative TMATMUL.

## Verification

Focused AVS points use distinct PE-local GPR values for four selected PEs and
prove that each derived range is evaluated independently while the parent
identity remains common.
