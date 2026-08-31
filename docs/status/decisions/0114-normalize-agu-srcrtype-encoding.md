---
{
  "id": "ADR-0114",
  "title": "Normalize the AGU SrcRType arithmetic modifier encoding",
  "status": "accepted",
  "authors": ["Codex"],
  "approvers": ["zhoubot"],
  "created": "2026-09-01",
  "accepted": "2026-09-01",
  "rejected": null,
  "superseded": null,
  "baseline": "a99ded8ea5365ffedd85c7f376651c3378456391",
  "target_releases": ["0.58.5"],
  "affected_ndf": [
    "PTO-INST-SCALAR-HL-LB-PO",
    "PTO-INST-SCALAR-HL-LB-PR",
    "PTO-INST-SCALAR-HL-LBP",
    "PTO-INST-SCALAR-HL-LBU-PO",
    "PTO-INST-SCALAR-HL-LBU-PR",
    "PTO-INST-SCALAR-HL-LBUP",
    "PTO-INST-SCALAR-HL-LD-PO",
    "PTO-INST-SCALAR-HL-LD-PR",
    "PTO-INST-SCALAR-HL-LDP",
    "PTO-INST-SCALAR-HL-LH-PO",
    "PTO-INST-SCALAR-HL-LH-PR",
    "PTO-INST-SCALAR-HL-LHP",
    "PTO-INST-SCALAR-HL-LHU-PO",
    "PTO-INST-SCALAR-HL-LHU-PR",
    "PTO-INST-SCALAR-HL-LHUP",
    "PTO-INST-SCALAR-HL-LW-PO",
    "PTO-INST-SCALAR-HL-LW-PR",
    "PTO-INST-SCALAR-HL-LWP",
    "PTO-INST-SCALAR-HL-LWU-PO",
    "PTO-INST-SCALAR-HL-LWU-PR",
    "PTO-INST-SCALAR-HL-LWUP",
    "PTO-INST-SCALAR-HL-PRF",
    "PTO-INST-SCALAR-HL-PRF-A",
    "PTO-INST-SCALAR-HL-SB-PO",
    "PTO-INST-SCALAR-HL-SB-PR",
    "PTO-INST-SCALAR-HL-SBP",
    "PTO-INST-SCALAR-HL-SD-PO",
    "PTO-INST-SCALAR-HL-SD-PR",
    "PTO-INST-SCALAR-HL-SD-UPO",
    "PTO-INST-SCALAR-HL-SD-UPR",
    "PTO-INST-SCALAR-HL-SDP",
    "PTO-INST-SCALAR-HL-SDP-U",
    "PTO-INST-SCALAR-HL-SH-PO",
    "PTO-INST-SCALAR-HL-SH-PR",
    "PTO-INST-SCALAR-HL-SH-UPO",
    "PTO-INST-SCALAR-HL-SH-UPR",
    "PTO-INST-SCALAR-HL-SHP",
    "PTO-INST-SCALAR-HL-SHP-U",
    "PTO-INST-SCALAR-HL-SW-PO",
    "PTO-INST-SCALAR-HL-SW-PR",
    "PTO-INST-SCALAR-HL-SW-UPO",
    "PTO-INST-SCALAR-HL-SW-UPR",
    "PTO-INST-SCALAR-HL-SWP",
    "PTO-INST-SCALAR-HL-SWP-U",
    "PTO-INST-SCALAR-LB",
    "PTO-INST-SCALAR-LBU",
    "PTO-INST-SCALAR-LD",
    "PTO-INST-SCALAR-LH",
    "PTO-INST-SCALAR-LHU",
    "PTO-INST-SCALAR-LW",
    "PTO-INST-SCALAR-LWU",
    "PTO-INST-SCALAR-PRF",
    "PTO-INST-SCALAR-SB",
    "PTO-INST-SCALAR-SD",
    "PTO-INST-SCALAR-SD-U",
    "PTO-INST-SCALAR-SH",
    "PTO-INST-SCALAR-SH-U",
    "PTO-INST-SCALAR-SW",
    "PTO-INST-SCALAR-SW-U",
    "PTO-REQ-AGU-SRCRTYPE-001"
  ],
  "affected_units": [
    "PTO-SCALAR-HL-LB-PO",
    "PTO-SCALAR-HL-LB-PR",
    "PTO-SCALAR-HL-LBP",
    "PTO-SCALAR-HL-LBU-PO",
    "PTO-SCALAR-HL-LBU-PR",
    "PTO-SCALAR-HL-LBUP",
    "PTO-SCALAR-HL-LD-PO",
    "PTO-SCALAR-HL-LD-PR",
    "PTO-SCALAR-HL-LDP",
    "PTO-SCALAR-HL-LH-PO",
    "PTO-SCALAR-HL-LH-PR",
    "PTO-SCALAR-HL-LHP",
    "PTO-SCALAR-HL-LHU-PO",
    "PTO-SCALAR-HL-LHU-PR",
    "PTO-SCALAR-HL-LHUP",
    "PTO-SCALAR-HL-LW-PO",
    "PTO-SCALAR-HL-LW-PR",
    "PTO-SCALAR-HL-LWP",
    "PTO-SCALAR-HL-LWU-PO",
    "PTO-SCALAR-HL-LWU-PR",
    "PTO-SCALAR-HL-LWUP",
    "PTO-SCALAR-HL-PRF",
    "PTO-SCALAR-HL-PRF-A",
    "PTO-SCALAR-HL-SB-PO",
    "PTO-SCALAR-HL-SB-PR",
    "PTO-SCALAR-HL-SBP",
    "PTO-SCALAR-HL-SD-PO",
    "PTO-SCALAR-HL-SD-PR",
    "PTO-SCALAR-HL-SD-UPO",
    "PTO-SCALAR-HL-SD-UPR",
    "PTO-SCALAR-HL-SDP",
    "PTO-SCALAR-HL-SDP-U",
    "PTO-SCALAR-HL-SH-PO",
    "PTO-SCALAR-HL-SH-PR",
    "PTO-SCALAR-HL-SH-UPO",
    "PTO-SCALAR-HL-SH-UPR",
    "PTO-SCALAR-HL-SHP",
    "PTO-SCALAR-HL-SHP-U",
    "PTO-SCALAR-HL-SW-PO",
    "PTO-SCALAR-HL-SW-PR",
    "PTO-SCALAR-HL-SW-UPO",
    "PTO-SCALAR-HL-SW-UPR",
    "PTO-SCALAR-HL-SWP",
    "PTO-SCALAR-HL-SWP-U",
    "PTO-SCALAR-LB",
    "PTO-SCALAR-LBU",
    "PTO-SCALAR-LD",
    "PTO-SCALAR-LH",
    "PTO-SCALAR-LHU",
    "PTO-SCALAR-LW",
    "PTO-SCALAR-LWU",
    "PTO-SCALAR-MODEL-DISPATCH-AGU",
    "PTO-SCALAR-MODEL-DISPATCH-DECODE",
    "PTO-SCALAR-PRF",
    "PTO-SCALAR-SB",
    "PTO-SCALAR-SD",
    "PTO-SCALAR-SD-U",
    "PTO-SCALAR-SH",
    "PTO-SCALAR-SH-U",
    "PTO-SCALAR-SW",
    "PTO-SCALAR-SW-U"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/193",
  "release_impact": "required",
  "legacy_ids": []
}
---

# ADR 0114: Normalize the AGU SrcRType arithmetic modifier encoding

## Context

Register-offset AGU instructions carry the shared two-bit `SrcRType` field.
PTO-SPEC assigned a numeric order that conflicted with the 0.58.5 compiler and
binary contract. Consequently an unmodified compiler-generated offset
(`SrcRType=3`) was negated by PTO-SPEC. A real scalar loop loaded the correct
word for index zero but addressed before the array for index one.

The 0.58.5 arithmetic modifier contract uses one shared mapping for `LW` and
the other register-offset AGU forms. Plain operands encode `11`, while `.sw`,
`.uw`, and `.neg` encode `00`, `01`, and `10` respectively.

## Decision

Every scalar register-offset AGU form uses the 0.58.5 arithmetic modifier
mapping:

- `00` sign-extends `SrcR[31:0]` (`.sw`);
- `01` zero-extends `SrcR[31:0]` (`.uw`);
- `10` negates the complete PTO_XLEN `SrcR` value (`.neg`);
- `11` leaves the complete PTO_XLEN `SrcR` value unchanged.

The modifier is applied before the encoded or fixed left shift. The mapping is
uniform across loads, stores, pairs, prefetches, and update forms that carry
`SrcRType`.

## Compatibility

- Encodings and assembly spellings do not change.
- Existing 0.58.5 binaries now execute with their intended plain and suffixed
  register-offset meanings.
- Binaries that relied on PTO-SPEC's conflicting numeric mapping change
  meaning and are not 0.58.5-compatible inputs.
- Memory alignment, translation, permissions, event ordering, restart, and
  destination rules are unchanged.
- Hosted ELF loading and runner transport remain model concerns outside this
  architecture decision.

## Verification obligations

- Decode all four `SrcRType` values to the selected transformation.
- Prove modifier-before-shift address formation for representative load and
  store forms.
- Execute the compiler-emitted plain `LW` encoding with `SrcRType=3` across at
  least two loop iterations and observe increasing addresses.
- Keep generated mnemonic contracts, documentation, catalogs, and release
  evidence synchronized.

## Decision state

The architecture owner authorized autonomous detailed analysis and the
recommended architecture rule on 2026-09-01. Focused mapping and ELF-shaped
loop tests bind the decision to the owning ASL.
