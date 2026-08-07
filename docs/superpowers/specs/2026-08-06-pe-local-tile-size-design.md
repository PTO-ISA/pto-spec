# PTO ISA 0.58 PE-Local Tile Size and Dimension Design

## Status

Approved architecture direction for Issues 48 and 49. This design replaces the
earlier PTO ISA 0.58 tile-size, dimension, and Shared binder interpretation in
place. It does not create a new release number or ABI version suffix. It replaces
the active 16-bit `C.B.IOS` form with one 32-bit `B.IOS` form while keeping the
accepted command-form count unchanged.

## Objective

PTO ISA 0.58 SHALL define Tile dimensions and Tile allocation size at the
single-PE level. A block's `PE_MASK` SHALL identify which PE instances execute
and receive destination storage. Core-level physical allocation SHALL equal the
single-PE allocation multiplied by the number of selected PEs.

The reissued 0.58 specification SHALL supersede the earlier 0.58 interpretation.
All 0.58 toolchains and artifacts SHALL be regenerated from the new release
manifest. No compatibility path for artifacts produced from the superseded
interpretation is required.

## Release Identity and Unchanged Surrounding Encodings

The following encoded surfaces SHALL NOT change:

- `B.IOT.PE_MASK[18:15]`;
- `B.IOT.TSize[11:9]`;
- `B.IOT.DstTile[8:7]`;
- `B.DIM` field layout and loop-bound selectors;
- the PTO ISA release string `0.58.0`; and
- the existing `encoding_abi` identity string.

The change is a replacement of the programming and architectural semantics
associated with those existing fields. The regenerated release manifest and its
canonical content hash identify the superseding 0.58 specification tree.

## 32-bit Shared Operand Binder

The active Shared operand binder SHALL be `B.IOS`. The old 16-bit `C.B.IOS`
mnemonic and form SHALL be removed from the active catalog and rejected by the
assembler. Its historical raw bit pattern overlaps the still-active
`C.B.DIMI` form, so a decoder sees those bits only as `C.B.DIMI`; raw bits do
not retain the retired mnemonic's provenance. `B.IOS` SHALL occupy the same
32-bit Bundle Input & Output opcode group as `B.IOR` and `B.IOT`:

```text
width       = 32
opcode      = 0x13
funct3      = 001
match       = 0x00001013
mask        = 0xf00871ff
SharedTID   = instruction[27:20]
PE_MASK     = instruction[18:15]
TSize       = instruction[11:9]
```

Bits `[31:28]`, bit `[19]`, and bits `[8:7]` SHALL be zero. The catalog
`semantic_group` SHALL be `Bundle Input & Output`; the semantic handler SHALL
remain `BindBundleSharedIO`.

Canonical source and destination forms SHALL be:

```asm
B.IOS S12, mask=1111
B.IOS mask=0011, ->S12<001>
```

`TSize=000` SHALL identify a Shared source binding. `TSize=001..111` SHALL
identify a Shared destination binding and declare its per-PE capacity using the
table below. The role encoded by `TSize` MUST agree with the selected `BSTART`
operation schema. A mismatch SHALL raise `Fault_TileLegality` before payload,
descriptor, memory, allocation, rename, consume, or lifetime effects.

One `B.IOS` binds one absolute Shared register `S0..S255`. Bindings are ordered,
at most four may be live, duplicate unconsumed IDs are illegal, and successful
operations consume exactly the bindings required by their schema. Trap state
SHALL preserve `SharedTID`, `TSize`, `PE_MASK`, validity, and consumed state.

`B.IOR` SHALL bind scalar/address operands only. Its `RegDst` field SHALL NOT be
reinterpreted as Shared size. `B.IOT` SHALL bind Local Tile operands only and
SHALL NOT have a mask-only Shared companion form. In a mixed Local/Shared
operation, every participating `B.IOT.PE_MASK` and `B.IOS.PE_MASK` MUST match.
Shared CUBE sources MUST use `TSize=000` and `PE_MASK=1111`; TGEMV MUST reject
all Shared bindings.

## PE Mask Bit Order

The four mask bits SHALL map to fixed PE identities and SHALL NOT pack selected
PEs into lower-numbered slots:

| `PE_MASK` bit | PE |
| --- | --- |
| `1000` | PE0 |
| `0100` | PE1 |
| `0010` | PE2 |
| `0001` | PE3 |

Multiple mask bits MAY be set. `PE_MASK=0000` SHALL be a strict no-op: it SHALL
NOT allocate or rename a destination, read a source, access Shared state or
memory, change descriptor state, advance lifetime state, or raise a fault.

## Per-PE TSize Encoding

`B.IOT.TSize` and destination `B.IOS.TSize` SHALL express the allocation size
of one selected PE:

| `TSize` | Per-PE size |
| --- | ---: |
| `000` | implicit or no explicit destination size, only where the operation schema permits it |
| `001` | 128 B |
| `010` | 256 B |
| `011` | 512 B |
| `100` | 1 KiB |
| `101` | 2 KiB |
| `110` | 4 KiB |
| `111` | 8 KiB |

For a destination-bearing operation with a legal nonzero `TSize`, Core-level
allocation SHALL be:

```text
allocated_bytes = popcount(PE_MASK) * per_pe_tsize_bytes
```

Examples for `TSize=001`:

| `PE_MASK` | Selected PEs | Per-PE allocation | Core allocation |
| --- | --- | ---: | ---: |
| `0001` | PE3 | 128 B | 128 B |
| `0011` | PE2, PE3 | 128 B each | 256 B |
| `1111` | PE0, PE1, PE2, PE3 | 128 B each | 512 B |

The `TILE_CAPACITY` accounting boundary SHALL count Core-level allocated bytes,
including the mask multiplier. A destination attempt that would exceed the
capacity SHALL fail precisely without partial allocation, rename, descriptor,
payload, or lifetime effects.

## Per-PE Dimensions

Every dimension consumed from `B.DIM` SHALL describe one PE's operand or result
view. This includes ordinary Tile valid-region dimensions and CUBE `M`, `N`, and
`K` dimensions.

Distribution metadata SHALL derive a group-level view when one is needed. For a
full-mask `MShard4` cooperative matrix operation:

```text
group_M = 4 * pe_M
group_N = pe_N
group_K = pe_K
```

The selected PE identity remains fixed for partial masks; selected fragments are
not packed. Cooperative TMATMUL requires `PE_MASK=1111`, so its architectural
group result contains all four M shards. Other distribution kinds SHALL define
their own group derivation rather than inheriting an unconditional multiply-by-4
rule.

## Local Tile Allocation and Rename

Local T/U/M/N destinations SHALL be allocated independently for each selected
PE. The destination descriptor's shape and capacity are per-PE values. Hardware
rename SHALL resolve Local sources to the correct per-PE physical producer;
consumers do not use `PE_MASK` as a source-data selector.

The formal one-level direct-operation carrier MAY continue to represent the
already-resolved current-PE Tile fragment. Bundle allocation state SHALL retain
the allocation mask needed for Core-level capacity accounting. This abstraction
MUST NOT describe `capacity_bytes` or `B.DIM` as a four-PE logical aggregate.

## Shared Register Allocation

Each Core retains absolute Shared registers `S0` through `S255`. A Shared
register allocation SHALL record:

- one per-PE descriptor, including per-PE shape and per-PE capacity;
- an immutable nonzero `allocation_mask` fixed by the first allocating write;
- an `initialized_mask` that is a subset of `allocation_mask`; and
- Core-level allocated bytes equal to
  `popcount(allocation_mask) * per_pe_capacity_bytes`.

The first allocating write SHALL use its effective `PE_MASK` as the Shared
register's `allocation_mask`. A subsequent destination write MAY select any
subset of that allocation mask and SHALL preserve unselected PE state. A write
whose mask contains a bit outside the recorded allocation mask SHALL be illegal
for that register. The compiler SHALL allocate a new `Sx` when a larger or
different PE allocation mask is required.

The per-PE descriptor, including size, shape, dtype, layout, and role, SHALL
remain compatible for the lifetime of the Shared allocation. A different
descriptor requires a newly allocated Shared register. A zero-mask operation
does not establish an allocation.

Reading an unallocated or uninitialized Shared PE lane SHALL retain the approved
undefined-register behavior: it SHALL NOT trap, allocate storage, initialize the
lane, or modify the descriptor. Shared destination updates remain atomic
descriptor-plus-selected-payload operations. The architecture continues to
provide no order for conflicting concurrent accesses.

## Data Movement

- Local `TLOAD`, `TMOV`, and destination-bearing TLSU operations SHALL use
  per-PE shape and per-PE `TSize`.
- GM-to-Shared destination size and mask SHALL come directly from `B.IOS`.
- Shared-to-GM source bindings SHALL use `B.IOS.TSize=000`; their descriptor
  supplies the already allocated per-PE capacity.
- Local-to-Shared `TMOV` SHALL take the Shared destination size from `B.IOS`;
  its `B.IOT` remains a Local source binder.
- Shared-to-Local `TMOV` SHALL take the Shared source and mask from `B.IOS` and
  the Local destination capacity from `B.IOT`.
- `PE_MASK` SHALL determine which fixed PE Shared lanes are allocated or
  accessed; selected lanes are not packed.
- `GMOV` SHALL transfer one already-renamed PE-local fragment. Its `TSize`
  SHALL describe that fragment, not a four-PE logical aggregate.
- Source-only stores may continue to derive size from their source descriptor,
  but that descriptor size is per-PE.

## Cooperative Matrix Operations

For cooperative TMATMUL, `B.DIM M/N/K` SHALL be per-PE. Each PE consumes its own
resolved Local or Shared operand fragments and produces a per-PE destination of
shape `M x N`. `MShard4` derives the full four-PE result by fixed PE identity,
not by changing the encoded dimensions or `TSize`.

Shared Right operands SHALL expose one per-PE fragment under the Shared
allocation mask. The compiler is responsible for allocating and populating the
required Shared PE lanes. The ISA does not imply that different PE lanes contain
identical values unless an operation or distribution contract explicitly
requires that property.

## Versioning and Re-Release

The repository SHALL continue to publish PTO ISA `0.58.0`. It SHALL not add a
`v2` encoding or programming-ABI suffix. The previous 0.58 Tile-size and
dimension interpretation is superseded rather than retained as a selectable
profile.

The regenerated release manifest, source locks, generated projections, and
release notes SHALL identify the replacement tree. Toolchains SHALL rebuild all
0.58 objects and images against that tree. The release documentation SHALL warn
that artifacts produced from the superseded 0.58 interpretation are stale and
must not be mixed with the reissued toolchain.

## Required Specification Changes

The implementation SHALL update, at minimum:

- one accepted architecture decision for Issues 48 and 49 that defines the
  PE-local size/allocation contract and supersedes the Shared-binder part of
  ADR 0052;
- architecture, programming-model, state/type, and encoding-convention pages;
- new `B.IOS` documentation, removal of active `C.B.IOS` documentation, and
  updates to `B.IOT`, `B.IOR`, `B.DIM`, `TLOAD`, `TSTORE`, `TMOV`, `GMOV`, and
  all cooperative TMATMUL pages;
- the command catalog and encoding workbook, with `B.IOS` in semantic group
  `Bundle Input & Output` and no unreviewed encoding overlap;
- ASL size decoding, allocation accounting, zero-mask behavior, destination
  resolution, complete Shared binding state, Shared allocation-mask legality,
  removal of the `B.IOR.RegDst` size carrier and mask-only `B.IOT`, and relevant
  model comments;
- executable tests for every size code, PE-mask population count, fixed bit
  order, zero-mask no-op, Shared subset update, Shared expansion rejection, and
  per-PE dimension behavior;
- catalog semantic summaries, generated HTML/Excel projections, evidence, and
  release manifest; and
- Issue 48 with the accepted decision and exact merged commit.

The accepted command-form count SHALL remain 99: one active `C.B.IOS` form is
removed and one active `B.IOS` form is added.

## Acceptance Criteria

1. Every normative and generated size table maps `001..111` to per-PE
   `128B..8KB`.
2. Capacity accounting proves the mask multiplier for one, two, three, and four
   selected PEs.
3. `0000` canaries prove the absence of allocation, rename, reads, writes,
   faults, and lifetime changes.
4. Shared allocation-mask tests permit subset updates and reject expansion of an
   existing `Sx`.
5. Matrix tests prove that encoded `M/N/K` and destination shape are per-PE while
   full-mask MShard4 derives a four-times-larger group M extent.
6. Repository/catalog/release checks pass from a clean tree.
7. The reissued 0.58 release manifest is regenerated from the reviewed exact
   head, and its generated projections are clean.
8. Raw-word overlap checks prove that `B.IOS` does not overlap `B.IOR`, any
   `B.IOT` variant, scalar forms, or reserved Linx-only vector encodings.
9. Decoder canaries reject nonzero reserved bits and the retired active
   `C.B.IOS` encoding.

## Rejected Alternatives

- Keeping the previous logical-Tile size table while describing dimensions as
  per-PE leaves allocation and shape at different architectural levels.
- Adding a new `v2` encoding or release number contradicts the approved in-place
  0.58 replacement.
- Allowing an existing Shared register to grow its allocation mask hides a new
  physical allocation behind a partial update; a new `Sx` is required instead.
- Using `PE_MASK` to select Local source data conflicts with per-PE hardware
  rename and is not part of this contract.
- Reusing `B.IOR.RegDst` for Shared size makes scalar operand state carry Tile
  allocation metadata and leaves no clean Shared mask owner.
- A mask-only or destination-free `B.IOT` is binary-ambiguous with an existing
  Local T destination and therefore cannot be an architectural form.
- Retaining active `C.B.IOS` beside `B.IOS` creates two binder ABIs and is not
  part of the approved clean-break 0.58 reissue.
- Updating prose without updating ASL and executable rejection evidence leaves
  the normative repository internally inconsistent.
