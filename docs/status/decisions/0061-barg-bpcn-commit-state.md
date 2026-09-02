---
{
  "id": "ADR-0061",
  "title": "Bundle commit state uses BARG/BPCN",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>",
    "Codex"
  ],
  "approvers": [
    "Kevin Zhou <zhoubot@gmail.com>",
    "zhoubot"
  ],
  "created": "2026-08-11",
  "accepted": "2026-08-11",
  "rejected": null,
  "superseded": null,
  "baseline": "4d115387b8a8a3c135f78189778d38547e75c697",
  "target_releases": [
    "0.58.1",
    "0.58.5"
  ],
  "affected_ndf": [
    "PTO-BARG-CONTINUATION-001",
    "PTO-BSTART-DECISION-BINDING-001",
    "PTO-BSTOP-DECISION-BINDING-001",
    "PTO-C-BSTOP-DECISION-BINDING-001",
    "PTO-C-SETC-TGT-SNAPSHOT-001",
    "PTO-L-BSTOP-DECISION-BINDING-001",
    "PTO-SETC-TGT-ADR-CONTRACT-001",
    "PTO-REQ-BSTART-PREDECESSOR-TRANSFER-001",
    "PTO-B-HINT-LIFECYCLE-001",
    "PTO-INST-BLOCK-B-HINT"
  ],
  "affected_units": [
    "PTO-BLOCK-BSTART",
    "PTO-BLOCK-BSTOP",
    "PTO-BLOCK-C-BSTOP",
    "PTO-BLOCK-L-BSTOP",
    "PTO-BLOCK-MODEL-STATE-BARG",
    "PTO-SCALAR-C-SETC-TGT",
    "PTO-SCALAR-SETC-TGT",
    "PTO-BLOCK-MODEL-DISPATCH-START",
    "PTO-BLOCK-B-HINT",
    "PTO-BLOCK-MODEL-DISPATCH-COMMANDS"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": [],
  "amendments": [
    {
      "date": "2026-09-01",
      "baseline": "3918b6aa0ffcc73be79699d4e18c15d8ccc13ba2",
      "approvers": [
        "zhoubot"
      ],
      "issue": "https://github.com/PTO-ISA/pto-spec/issues/192",
      "affected_ndf": [
        "PTO-REQ-BSTART-PREDECESSOR-TRANSFER-001"
      ],
      "affected_units": [
        "PTO-BLOCK-MODEL-DISPATCH-START"
      ]
    },
    {
      "date": "2026-09-01",
      "baseline": "6df97a3cf31aa83b2c90a8664c2ccb15ef74c8d9",
      "approvers": [
        "zhoubot"
      ],
      "issue": "https://github.com/PTO-ISA/pto-spec/issues/195",
      "affected_ndf": [
        "PTO-B-HINT-LIFECYCLE-001",
        "PTO-INST-BLOCK-B-HINT"
      ],
      "affected_units": [
        "PTO-BLOCK-B-HINT",
        "PTO-BLOCK-MODEL-DISPATCH-COMMANDS"
      ]
    }
  ]
}
---
# ADR 0061: Bundle commit state uses BARG/BPCN

- Date: 2026-08-11
- Requirements: PTO-REQ-BUNDLE-STATE-001,
  PTO-REQ-BUNDLE-DISPATCH-001, PTO-REQ-BUNDLE-OPERATION-001

## Context

The PTO block-lifecycle model carries a candidate target and a sequential
continuation but does not yet expose them through one complete architectural
bundle-argument record. The formal contract requires one current block address,
one candidate next block address, an explicit transfer kind, and an explicit
taken decision without creating duplicate target or trap fields.

## Decision

`BARG.BPC` is a 64-bit field containing the current BSTART address. Hardware
sets it when the block is initialized.

`BARG.BPCN` is a 64-bit field containing the candidate next block-head
address. `SETC.TGT` and `C.SETC.TGT` write this field. `TGT` and `BPC.TGT` are
alternate names for this same architectural value; they MUST NOT create a
second target field.

`BPCN`, `TYPE`, and `TAKEN` are valid only for STD and FP blocks. SYS blocks
have `BPC` and `BlockType`, plus their applicable ordering attributes, but do
not have these three block-transfer fields. PTO reserves no second meaning for
the physical BPCN storage.

`BARG.TYPE` records the block-transfer kind and `BARG.TAKEN` records whether
the candidate target is selected. At block commit:

- FALL and a false COND continue at the sequential next BSTART;
- STD/FP DIRECT, CALL, IND, ICALL, RET, and a true COND continue at
  `BARG.BPCN`;
- the selected continuation becomes the next block PC only after successful
  block commit.

Direct, call, indirect, indirect-call, and return forms initialize `TAKEN=1`.
FALL initializes `TAKEN=0`. Conditional forms initialize or update `TAKEN`
from their condition operation while retaining their encoded target in
`BPCN`.

BARG has no architectural `TRAP` field. Trap and exception state are handled
by the separate PTO trap/context model.

`BSTOP`, `C.BSTOP`, `L.BSTOP`, and a following BSTART are commit boundaries.
They MUST read the same BARG record, choose the continuation as above, commit
the current block atomically, and clear the retiring block's BARG and private
state after successful commit. A final block MUST end with a BSTOP form.

## Consequences

- PTO MUST replace parallel target explanations with one BARG/BPCN
  architectural definition while retaining an internal sequential continuation
  value where needed to model a false condition.
- The current `_BundleTarget` state maps to `BARG.BPCN`; it is not an
  independent architectural field.
- The current `_BundleFallthrough` value is implementation support for the
  sequential continuation; it is not BPCN.
- PTO legality must reject transfer forms on block types for which BARG does
  not provide `BPCN`, `TYPE`, and `TAKEN`.
- PTO ASL, instruction pages, AVS points, trap-context projection, and release
  evidence MUST use the same names, widths, initialization, selection, commit,
  and clearing rules.

## Evidence

- `asl/block/model/state/control-state.asl`
- `asl/block/model/lifecycle/begin.asl`
- `asl/block/model/lifecycle/enter-stop.asl`
- `asl/block/lifecycle/BSTART.asl`
- `asl/block/lifecycle/BSTOP.asl`
- `asl/block/lifecycle/C.BSTOP.asl`
- `asl/block/lifecycle/L.BSTOP.asl`

## Selected-boundary installation

A fetched following `BSTART` or `B.HINT TRACE` first commits its active
predecessor. It installs the fetched boundary only when the committed TPC
equals that instruction's PC. If the predecessor selected another direct,
conditional, indirect, call, or return continuation, the selected TPC remains
committed and the unselected-path boundary is not installed. Failed predecessor
commit preserves the prior rollback behavior.

Issues [#192](https://github.com/PTO-ISA/pto-spec/issues/192) and
[#195](https://github.com/PTO-ISA/pto-spec/issues/195) record the focused
control-flow evidence. This is part of the existing BARG/BPCN commit interface,
not a separate decision family.
