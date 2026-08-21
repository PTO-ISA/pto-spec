---
{
  "id": "ADR-0096",
  "title": "Re-encode B.IOT and B.IOS size and PE mode fields",
  "status": "accepted",
  "authors": ["ckwllawliet <641433195@qq.com>"],
  "approvers": ["zhoubot"],
  "created": "2026-08-20",
  "accepted": "2026-08-20",
  "rejected": null,
  "superseded": null,
  "baseline": "bc369ec67a07c0260f6ba793fa0d705abb363770",
  "target_releases": ["0.58.3"],
  "affected_ndf": [
    "PTO-ARCH-GM-ACCESS-001",
    "PTO-B-IOS-SHARED-STATE-001",
    "PTO-B-IOT-STREAM-001",
    "PTO-CUBE-ACCUMULATOR-OUTPUT-001",
    "PTO-TLOAD-CUBE-001",
    "PTO-TLOAD-MEMORY-001"
  ],
  "affected_units": [
    "PTO-ARCH-DATA-TYPES-INTEGER",
    "PTO-ARCH-FEATURES-TILE-ALLOCATION",
    "PTO-ARCH-MEMORY-MODEL-GLOBAL-MEMORY-ACCESS",
    "PTO-ARCH-PROFILE-RESET",
    "PTO-ARCH-PROGRAMMING-MODEL-CORE-PE-TOPOLOGY",
    "PTO-BLOCK-B-IOS",
    "PTO-BLOCK-B-IOT",
    "PTO-BLOCK-MODEL-DISPATCH-COMMANDS",
    "PTO-BLOCK-MODEL-DISPATCH-CUBE-TMATMUL",
    "PTO-BLOCK-MODEL-DISPATCH-DESTINATION-SHAPE",
    "PTO-BLOCK-MODEL-DISPATCH-SHARED-CUBE-MATRIX",
    "PTO-BLOCK-MODEL-DISPATCH-SHARED-TLSU",
    "PTO-BLOCK-MODEL-OPERANDS-SHARED-BINDINGS",
    "PTO-BLOCK-MODEL-OPERANDS-TILE-BINDINGS",
    "PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING",
    "PTO-BLOCK-MODEL-STATE-TYPES",
    "PTO-TILE-MODEL-DEFINEDNESS-ELEMENTS",
    "PTO-TILE-MODEL-DEFINEDNESS-PACKED-BOUNDARY",
    "PTO-TILE-MODEL-EXECUTION-COMPARISON",
    "PTO-TILE-MODEL-EXECUTION-COMPLEX",
    "PTO-TILE-MODEL-EXECUTION-CUBE",
    "PTO-TILE-MODEL-EXECUTION-ELEMENTWISE",
    "PTO-TILE-MODEL-EXECUTION-EXPANSION",
    "PTO-TILE-MODEL-EXECUTION-FUSED-MULTIPLY-ADD",
    "PTO-TILE-MODEL-EXECUTION-GENERATION",
    "PTO-TILE-MODEL-EXECUTION-IMAGE-TO-COLUMN",
    "PTO-TILE-MODEL-EXECUTION-INDEXED-REARRANGEMENT",
    "PTO-TILE-MODEL-EXECUTION-REARRANGEMENT",
    "PTO-TILE-MODEL-EXECUTION-REDUCTION",
    "PTO-TILE-MODEL-EXECUTION-SORTING",
    "PTO-TILE-MODEL-EXECUTION-UNARY",
    "PTO-TILE-MODEL-LEGALITY-ALLOCATION-CAPACITY",
    "PTO-TILE-MODEL-LEGALITY-DESCRIPTOR-SHAPE",
    "PTO-TILE-MODEL-LEGALITY-IMAGE-TO-COLUMN",
    "PTO-TILE-MODEL-LEGALITY-INDEXED-REARRANGEMENT",
    "PTO-TILE-MODEL-LEGALITY-MATRIX-INFO-DESCRIPTOR",
    "PTO-TILE-MODEL-LEGALITY-MATRIX-POSTPROCESS",
    "PTO-TILE-MODEL-LEGALITY-PE-MASK",
    "PTO-TILE-MODEL-MEMORY-LOAD-STORE",
    "PTO-TILE-MODEL-MEMORY-SHARED-MOVEMENT",
    "PTO-TILE-MODEL-NUMERIC-FORMATS",
    "PTO-TILE-MODEL-ORDERING-SORTING",
    "PTO-TILE-MODEL-SHAPE-VALID-REGION",
    "PTO-TILE-MODEL-STATE-ALLOCATION",
    "PTO-TILE-MODEL-STATE-DESCRIPTORS",
    "PTO-TILE-MODEL-STATE-FEATURE-MAP-DESCRIPTORS",
    "PTO-TILE-MODEL-STATE-SHARED-REGISTERS",
    "PTO-TILE-MODEL-STATE-TYPES",
    "PTO-TILE-TLOAD"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/118",
  "release_impact": "required",
  "legacy_ids": []
}
---

# ADR 0096: Re-encode B.IOT and B.IOS size and PE mode fields

## Context

The previous binders encoded a four-bit `PE_MASK` and a three-bit `TSize` in
different semantic roles. That layout cannot represent the proposed larger
per-PE capacities or give both Local and Shared binders one common mode
decoder. The new layout is an intentional encoding break. Release identity is
assigned separately and is not part of this architectural decision.

## Decision

`B.IOT` and `B.IOS` use the same encoded field locations:

```text
SizeCode = instruction[18:15]   // four bits
PEMode   = instruction[11:9]    // three bits
```

Opcode, funct3, instruction width, source order, Local destination ownership,
and `B.IOS.SharedTID = instruction[27:20]` remain unchanged. `B.IOS` bit 19
remains reserved and must be zero. No B.IOT form or selector is added.

The common pure decoder expands `PEMode` to the fixed four-PE semantic mask:

| PEMode | semantic mask |
| --- | --- |
| `000` | `0000` (none) |
| `001` | `1000` (PE0) |
| `010` | `0100` (PE1) |
| `011` | `0010` (PE2) |
| `100` | `0001` (PE3) |
| `101` | `1100` (PE0+PE1) |
| `110` | `1110` (PE0+PE1+PE2) |
| `111` | `1111` (all four PEs) |

`SizeCode=0` is source-only and never allocates. For B.IOT, destination
codes 1..10 represent 128 B through 64 KiB per participating PE; codes
11..15 are reserved. For B.IOS, destination codes 1..12 represent 128 B
through 256 KiB per participating PE; codes 13..15 are reserved. `PEMode=000`
is accepted for source-bearing forms but is a strict no-effect path before
placement, duplicate, schema, allocation, descriptor, memory, and downstream
fault checks. Reserved or malformed encodings reject before architectural
effects.

Core allocation remains `popcount(decoded_mask) * per-PE capacity`, with a
256 KiB aggregate bound. Fixed PE identities, mask immutability, ordering,
defaults, mixed Local/Shared mask equality, aliasing, rollback, and trap
contracts remain unchanged.

## Consequences

The mnemonic metadata, decoder witnesses, common dispatch path, generated
catalog, and instruction pages now expose `SizeCode` and `PEMode`. The
remaining capacity, descriptor/state, and downstream consumer projections use
this ADR as their active encoding decision. Binary words using the superseded
field layout do not retain their former meaning.

## Supersession

This ADR supersedes the active `PE_MASK`/`TSize` encoding and size portions of
ADR 0054 and the corresponding minimum/per-PE encoding portions of ADR 0013.
ADR 0054's retained binder ownership, source order, shared allocation-mask
immutability, and operation/fault ordering remain in force unless explicitly
changed by this decision. ADR 0013's retained capacity accounting, packed
storage, precision, and rollback decisions remain in force.

## Rejected Alternatives

- Keeping the four-bit mask leaves no common three-bit mode encoding and
  preserves the old size ceiling.
- Reusing `TSize` as a wider field without a common decoder leaves Local and
  Shared binders with different mode semantics.
- Adding a new B.IOT form or selector would change the approved form inventory
  and is unnecessary for the re-encoding.
- Preserving the previous field layout would leave the larger size classes and
  common mode decoder unrepresentable.
