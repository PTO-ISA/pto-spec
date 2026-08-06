# ADR 0054: PE-Local Tile Size and 32-bit Shared I/O Binding

- **Status**: accepted
- **Date**: 2026-08-06
- **Deciders**: PTO ISA maintainers

## Context

PTO ISA 0.58 originally described `TSize` using a four-PE aggregate size table
even though Tile dimensions and execution are programmed at PE granularity.
That mixed two architectural levels: encoded dimensions described one PE while
encoded capacity described the Core aggregate.

The active 16-bit `C.B.IOS` binder also carried only an absolute `SharedTID`.
GM-to-Shared `TLOAD` therefore reinterpreted `B.IOR.RegDst[11:9]` as a Shared
size, and Shared TLSU operations used a destination-free `B.IOT` as a mask-only
companion. That `B.IOT` spelling is binary-identical to an existing Local T
destination form and cannot round-trip unambiguously. Local-to-Shared `TMOV`
additionally borrowed the Local binder's destination-size field for a Shared
destination.

## Decision

PTO ISA 0.58 is reissued in place. The architecture version remains `0.58.0`
and the existing ABI string remains unchanged; the regenerated release manifest
and content hashes identify the replacement specification tree. Artifacts built
against the superseded 0.58 tree are stale and must not be mixed with the
reissued toolchain.

`B.DIM` dimensions and every explicit Tile destination `TSize` describe one
selected PE. The nonzero size table is 128 B, 256 B, 512 B, 1 KiB, 2 KiB,
4 KiB, and 8 KiB for codes 1 through 7. Core allocation is
`popcount(PE_MASK) * per_pe_size`. Mask bits map to fixed identities:
`1000=PE0`, `0100=PE1`, `0010=PE2`, and `0001=PE3`; selected PEs are never
packed. Mask zero is a strict no-op with no allocation, rename, source read,
memory access, state change, binder consumption, lifetime transition, or fault.

The active Shared operand binder is replaced by 32-bit `B.IOS`:

```text
width       = 32
opcode      = 0x13
funct3      = 001
match       = 0x00001013
mask        = 0xf00871ff
SharedTID   = bits[27:20]
PE_MASK     = bits[18:15]
TSize       = bits[11:9]
reserved    = bits[31:28], bit[19], bits[8:7] (all zero)
```

It belongs to catalog semantic group `Bundle Input & Output` and uses handler
`BindBundleSharedIO`. `TSize=0` denotes a Shared source; `TSize=1..7` denotes a
Shared destination and declares per-PE capacity. The encoded role must agree
with the selected operation schema. One instruction binds one absolute
Core-private register `S0..S255`; at most four ordered bindings may be live.
Duplicate unconsumed IDs and a fifth binding are illegal.

`B.IOS` owns Shared ID, role/size, and PE mask. `B.IOR` owns scalar/address
operands only and `RegDst` is zero in Shared TLSU schemas. `B.IOT` owns Local
Tile operands only and has no mask-only Shared form. Mixed Local/Shared
operations require equal masks. Shared CUBE operands are sources with
`TSize=0` and mask `1111`; TGEMV rejects every Shared binder.

The first nonzero allocating Shared write records an immutable allocation mask
and one per-PE descriptor. Later destination writes may update a subset but may
not expand the allocation mask; the compiler allocates a new `Sx` for a
different mask or incompatible descriptor. Reads of unallocated or
uninitialized Shared lanes retain undefined-register behavior: no trap and no
state change. Shared destination updates remain atomic descriptor-plus-selected-
payload operations. The architecture imposes no ordering on conflicting PE
accesses; programs must avoid conflicts.

For `MShard4`, encoded `M`, `N`, and `K` remain per-PE and the group view derives
`group_M=4*pe_M`, `group_N=pe_N`, and `group_K=pe_K`. Other distribution kinds
must define their own derivation.

## Consequences

- Active `C.B.IOS` is removed and rejected; active `B.IOS` is added, so the
  command-form count remains 99.
- The old reviewed `C.B.DIMI`/`C.B.IOS` overlap exception is removed.
- `BundleSharedBinding` gains `size_code` and `pe_mask`, including reset,
  consume, trap snapshot, and recovery behavior.
- GM-to-Shared `TLOAD` size and mask come from `B.IOS`; Shared stores use source
  `B.IOS`; Local-to-Shared `TMOV` takes Shared capacity from destination
  `B.IOS`; Shared-to-Local keeps Local capacity in destination `B.IOT`.
- All legality checks occur before memory, payload, descriptor, allocation,
  rename, destination finalization, or binder consumption effects.
- Catalogs, ASL, tests, requirements, Markdown, HTML, XLSX, evidence, release
  manifest, PTO consumers, and Linx ISA 0.58 locks must be regenerated.

## Supersession

ADR 0052 remains historical. This ADR supersedes its aggregate Tile-size table,
active `C.B.IOS` encoding, `B.IOR` Shared-size carrier, mask-only `B.IOT`
companion, and Shared binder schema. The retained operation inventory and
Linx-only reservations in ADR 0052 remain in force.

## Rejected Alternatives

- Keeping aggregate sizes leaves dimensions and capacity at different levels.
- Reusing `B.IOR.RegDst` keeps Tile allocation metadata in a scalar binder.
- A destination-free `B.IOT` is ambiguous with an existing Local T destination.
- Extending `C.B.IOS` cannot fit the approved ID, size, and mask contract.
- A separate direction bit is unnecessary because zero/nonzero `TSize` already
  distinguishes source and destination roles.
- Keeping both binders active creates two 0.58 ABIs and violates the approved
  clean break.
- A new 0.59 release or ABI-v2 suffix is not used; this decision replaces the
  earlier 0.58 design before toolchain stabilization.
