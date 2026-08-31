---
{
  "id": "ADR-0114",
  "title": "Align AGU SrcRType with the LinxISA arithmetic modifier encoding",
  "status": "draft",
  "authors": ["Codex"],
  "approvers": [],
  "created": "2026-09-01",
  "accepted": null,
  "rejected": null,
  "superseded": null,
  "baseline": "a99ded8ea5365ffedd85c7f376651c3378456391",
  "target_releases": ["0.58.5"],
  "affected_ndf": [
    "PTO-REQ-AGU-SRCRTYPE-001"
  ],
  "affected_units": [
    "PTO-SCALAR-MODEL-DISPATCH-AGU",
    "PTO-SCALAR-MODEL-DISPATCH-DECODE"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/193",
  "release_impact": "required",
  "legacy_ids": []
}
---

# ADR 0114: Align AGU SrcRType with the LinxISA arithmetic modifier encoding

## Context

Register-offset AGU instructions carry the shared two-bit `SrcRType` field.
PTO-SPEC assigned a different numeric order from LinxISA v0.58.5 and its Sail
model. Consequently an unmodified compiler-generated offset (`SrcRType=3`) was
negated by PTO-SPEC. A real scalar loop loaded the correct word for index zero
but addressed before the array for index one.

The LinxISA Sail source uses `apply_srcrtype_arith64` for `LW` and the other
register-offset AGU forms. Its mapping also matches the compiler/disassembler:
plain operands encode `11`, while `.sw`, `.uw`, and `.neg` encode `00`, `01`,
and `10` respectively.

## Decision

Every scalar register-offset AGU form uses the LinxISA v0.58.5 arithmetic
modifier mapping:

- `00` sign-extends `SrcR[31:0]` (`.sw`);
- `01` zero-extends `SrcR[31:0]` (`.uw`);
- `10` negates the complete PTO_XLEN `SrcR` value (`.neg`);
- `11` leaves the complete PTO_XLEN `SrcR` value unchanged.

The modifier is applied before the encoded or fixed left shift. The mapping is
uniform across loads, stores, pairs, prefetches, and update forms that carry
`SrcRType`.

## Compatibility

- Encodings and assembly spellings do not change.
- Existing binaries produced by the LinxISA compiler now execute with their
  intended plain and suffixed register-offset meanings.
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
recommended architecture rule on 2026-09-01. This draft binds the exact
baseline before implementation and focused evidence promote it to accepted.
