---
{
  "id": "ADR-0120",
  "title": "Bind frame lifecycle to architectural sp GPR1",
  "status": "accepted",
  "authors": ["Codex"],
  "approvers": ["zhoubot"],
  "created": "2026-09-01",
  "accepted": "2026-09-01",
  "rejected": null,
  "superseded": null,
  "baseline": "62948f7dde41a4ede05fe424648ef3372fe220e6",
  "target_releases": ["0.58.5"],
  "affected_ndf": [
    "PTO-FENTRY-RESTARTABLE-FRAME-001",
    "PTO-FEXIT-RESTARTABLE-FRAME-001",
    "PTO-FRET-RA-RESTARTABLE-FRAME-001",
    "PTO-FRET-STK-RESTARTABLE-FRAME-001",
    "PTO-INST-BLOCK-FENTRY",
    "PTO-INST-BLOCK-FEXIT",
    "PTO-INST-BLOCK-FRET-RA",
    "PTO-INST-BLOCK-FRET-STK"
  ],
  "affected_units": [
    "PTO-BLOCK-FENTRY",
    "PTO-BLOCK-FEXIT",
    "PTO-BLOCK-FRET-RA",
    "PTO-BLOCK-FRET-STK",
    "PTO-BLOCK-MODEL-LIFECYCLE-LIFETIME"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/203",
  "release_impact": "required",
  "legacy_ids": []
}
---

# ADR 0120: Bind frame lifecycle to architectural sp GPR1

## Context

The PTO absolute-GPR map assigns selector zero to `zero`, selector one to
`sp`, selector two to `a0`, and selector ten to `ra`.  The frame-lifecycle ASL
instead used GPR2 as its implicit stack pointer.  Its focused fixtures repeated
that error, so isolated FENTRY/FEXIT/FRET tests did not expose the conflict.

In a compiler-generated ELF, scalar stack-address instructions used GPR1 while
FENTRY and FRET.STK used GPR2.  FRET.STK therefore restored from the wrong
frame even though the actual saved RA slot still contained the correct return
PC.

## Decision

- FENTRY, FEXIT, FRET.RA, and FRET.STK use architectural `sp`, absolute GPR1,
  for every implicit stack read and write.
- The explicit saved/restored register ring remains R2 through R23.  The
  implicit stack pointer is not reinterpreted as the first ring member.
- FENTRY snapshots the selected range before subtracting the frame size from
  GPR1.  Exit and return forms add the frame size to GPR1 before loading slots.
- Frame slot order, access sizes, restart boundaries, target validation,
  depth accounting, and TPC publication remain unchanged.

## Compatibility

- Encodings and assembly syntax do not change.
- Binaries already name `sp` through the established GPR1 ABI and now execute
  consistently across scalar addressing and frame lifecycle.
- The prior PTO executable model behavior using GPR2 was incorrect and is not
  a compatible architectural profile.

## Verification obligations

- All FENTRY/FEXIT/FRET.RA/FRET.STK points seed and observe GPR1 as `sp`.
- A range beginning at R2 stores the explicit R2 value, not the caller SP.
- FENTRY followed by an in-frame arbitrary-length MSET and FRET.STK preserves
  the saved RA and S0 slots and returns to the exact target.
- A compiler-generated memory ELF completes its frame return without entering
  zero-address memory.

## Decision state

The architecture owner confirmed this corrective architecture binding on
2026-09-01.
