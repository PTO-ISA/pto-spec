---
{
  "id": "ADR-0066",
  "title": "ADDTPC page-scaled immediate",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "created": "2026-08-18",
  "accepted": "2026-08-18",
  "rejected": null,
  "superseded": null,
  "baseline": "1ab747bae485806b0ab73212baa9abf454856c39",
  "target_releases": [
    "unassigned"
  ],
  "affected_ndf": [
    "PTO-ADDTPC-PAGE-001",
    "PTO-HL-ADDTPC-PAGE-001"
  ],
  "affected_units": [
    "PTO-SCALAR-ADDTPC",
    "PTO-SCALAR-HL-ADDTPC"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": []
}
---
# ADR 0066: ADDTPC page-scaled immediate

- Scope: `ADDTPC`, `HL.ADDTPC`
- Requirements: PTO-ADDTPC-PAGE-001, PTO-HL-ADDTPC-PAGE-001
- Supersedes: only the ADDTPC and HL.ADDTPC halfword-scaling clauses of ADR
  0021 and ADR 0027

## Decision

`ADDTPC` computes `TPC + (SignExtend(imm20) << 12)`. `HL.ADDTPC` computes
`TPC + (SignExtend(imm32) << 12)`. Both additions wrap at XLEN and use the
current instruction TPC before normal scalar retirement. Encoded immediate
zero therefore produces the current instruction TPC.

Both instructions write through the existing Reg5 destination behavior. They
do not install a control-flow target and do not directly advance TPC. The
scalar dispatch boundary advances TPC by four bytes for `ADDTPC` and six bytes
for `HL.ADDTPC` after a successful instruction effect.

The immediate scale is a 4 KiB page unit so the result can serve as the high
part of a PC-relative address and be combined with a separate low 12-bit add.

## Protected behavior

This decision changes no encoding, field width, field placement, mask, match,
assembly spelling, destination selector rule, or exception. Relative branches,
`J`, `JR`, `SETRET`, `HL.SETRET`, and `C.SETRET` retain their existing
halfword-scaled contracts.
