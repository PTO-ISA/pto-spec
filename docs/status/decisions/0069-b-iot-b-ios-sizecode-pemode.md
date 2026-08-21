# ADR 0069: Re-encode B.IOT and B.IOS size and PE mode fields

- Status: proposed; merge-gated
- Date: 2026-08-20
- Deciders: pending PTO ISA maintainer review
- Contract: https://github.com/PTO-ISA/pto-spec/issues/118
- Reviewer precedent: https://github.com/PTO-ISA/pto-spec/issues/113#issuecomment-5359572490
- Release: post-0.58.3 PTO ISA 0.59.0; `pto-isa-0.59.0-mode-function-v2`
- Merge gate: PTO 0.58.3 must be published before this implementation may merge.

## Context

NDF #118 is the active proposed contract for this implementation. It does not
reopen closed #113 or treat its former handoff as accepted. The current architecture
stack remains on the 0.58 release line until PTO 0.58.3 is published; this
candidate is intentionally the first post-0.58.3 hard break.

The 0.58 binders encoded a four-bit `PE_MASK` and a three-bit `TSize` in
different semantic roles. That layout cannot represent the proposed larger
per-PE capacities or give both Local and Shared binders one common mode
decoder. The change is an intentional ABI break; the 0.58.2 mode-function
ABI is not a compatibility target.

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
remaining capacity, descriptor/state, ABI version, and downstream consumer
projections are staged separately and must use this ADR as their active
encoding decision. Existing 0.58.2 binaries are intentionally rejected by
the 0.59.0 ABI. An implementation PR may be reviewed early, but it must not
merge until PTO 0.58.3 has been published; no current tree or evidence claim
asserts that publication has occurred.

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
- Preserving the 0.58.2 ABI would make the intentional 0.59.0 encoding break
  ambiguous and allow incompatible binaries to be mixed.
