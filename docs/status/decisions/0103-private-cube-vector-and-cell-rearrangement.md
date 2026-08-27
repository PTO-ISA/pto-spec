---
{
  "id": "ADR-0103",
  "title": "Private CUBE vector execution and CELL rearrangement",
  "status": "accepted",
  "authors": [
    "Codex"
  ],
  "approvers": [
    "zhoubot"
  ],
  "created": "2026-08-25",
  "accepted": "2026-08-25",
  "rejected": null,
  "superseded": null,
  "baseline": "23c577a468f443638e0353905f6303ed6b3ae2ed",
  "target_releases": [
    "unassigned"
  ],
  "affected_ndf": [
    "PTO-TPACK-CONTRACT-001",
    "PTO-TPERMUTE-CONTRACT-001",
    "PTO-TSHUF-CONTRACT-001",
    "PTO-TUNPACK-CONTRACT-001"
  ],
  "affected_units": [
    "PTO-TILE-TPACK",
    "PTO-TILE-TPERMUTE",
    "PTO-TILE-TSHUF",
    "PTO-TILE-TUNPACK"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/151",
  "release_impact": "required",
  "legacy_ids": []
}
---

# ADR 0103: Private CUBE vector execution and CELL rearrangement

## Context

Issue #151 was accepted by the architecture owner on 2026-08-25. This record
keeps one coherent decision for private Local CUBE vector execution and the
four CELL rearrangement operations, and establishes accepted ADR ownership for
their four contract clauses and instruction subjects. Current normative
meaning remains in the accepted ASL contracts and their generated projections.

## Decision

The six old tile selectors are retired: `TPARTADD`, `TPARTMUL`, `TPARTMAX`, and
`TPARTMIN` (`0x071..0x074`), `TFILLPAD` (`0x065`), and `TTRANS` (`0x06E`). Their
selectors remain reserved-illegal. No alias or replacement is introduced.
This retires only the corresponding decisions in ADR-0082 and ADR-0083; those
ADRs are not retired wholesale. This ADR intentionally does not use metadata
`supersedes` for that scoped retirement.

The following 34 existing element-wise instructions accept ordinary Local
`CUBE_M32` and Local `CUBE_M16` execution:

```text
TADD TAND TDIV TMAX TMIN TMUL TOR TREM TSHL TSHR TSUB TXOR
TABS TEXP TLOG TNEG TNOT TRECIP TRELU TRSQRT TSQRT
TADDS TANDS TDIVS TMAXS TMINS TMULS TORS TREMS
TSHLS TSHRS TSUBS TXORS TFMA
```

`CUBE_N8`, Shared layouts, mixed layouts, and the excluded `TCMP`, `TCMPS`,
`TSEL`, `TSELS`, and `TCVT` forms remain illegal. Existing logical-coordinate
element-wise contracts continue to define shape, type, valid-region, and value
behavior; this decision does not introduce a new element-wise spelling.

The SFU TEPL `Mode=3` selectors for CELL rearrangement are frozen as follows:

- `TPERMUTE` is selector `0x075`, a raw two-source per-row byte lookup using a
  U8 index Tile.
- `TSHUF` is selector `0x076`, a raw U32-word shuffle with `UP`, `DOWN`,
  `BFLY`, and `IDX` modes, `SELF`/`ZERO` selection, and M32/M16 grouping.
- `TPACK` is selector `0x077`, U32 byte-field assembly.
- `TUNPACK` is selector `0x078`, U32 zero-extended byte-field extraction.

Controls, operand bindings, source-definedness, valid-region and padding
inspection, and fresh-destination allocation follow and agree with the
accepted ASL contracts and the issue handoff. This ADR does not add alternate
control encodings or operand forms.

For a decoded bundle, missing, repeated, or surplus `B.IOR` structure is a
`BundleControl` fault. Invalid controls, indices, dtypes, layouts, or shapes
are `TileLegality` faults. An unallocated selector is an
`IllegalInstruction`. `PE_MASK=0000` is a strict no-op after legal decode and
does not read operands, allocate a destination, or raise a later semantic
fault.

## Compatibility and protected behavior

Raw CELL order is observable only for `TPERMUTE`, `TSHUF`, `TPACK`, and
`TUNPACK`. Ordinary element-wise operations remain logical-coordinate based.
This decision does not add reductions, replace transpose, enable GM
conversion, add predicate behavior, or define numeric conversion semantics.

The selector retirement is an assembly and compatibility break: the retired
encodings are rejected and have no compatibility aliases. Compiler intrinsic,
emulator, and RTL adoption remain separate follow-ups to the PTO-ASL contract.

## Release boundary

The change has required release impact and its target remains `unassigned`.
This ADR does not select or change an architecture version, publication
identity, `spec/release-selection.json`, release manifest, compatibility policy
or compatibility ADR, tag, release, or external NDF submodule pin. It does not
claim V2 evidence. Those are separate release work and blockers.

## Verification

Focused decoded and direct AVS evidence covers the accepted vector and CELL
rearrangement paths, rejection/no-effect boundaries, and the bundle fault
boundary. The ordinary PR V1 gates are the applicable repository verification;
release validation and V2 evidence are not claimed by this decision.
