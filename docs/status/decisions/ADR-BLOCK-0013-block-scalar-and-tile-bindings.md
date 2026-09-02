---
{
  "id": "ADR-BLOCK-0013",
  "title": "Block scalar and tile bindings",
  "title_zh": "Block 标量与 Tile 绑定",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "created": "2026-08-21",
  "accepted": "2026-08-21",
  "rejected": null,
  "superseded": null,
  "baseline": "1e91bf98ad2f918c24ddbb394c3be73fa9d5de9f",
  "target_releases": [
    "0.58.1",
    "0.58.2"
  ],
  "affected_ndf": [
    "PTO-B-IOR-BINDING-001",
    "PTO-B-IOS-SHARED-STATE-001",
    "PTO-B-IOT-STREAM-001"
  ],
  "affected_units": [
    "PTO-BLOCK-B-IOR",
    "PTO-BLOCK-B-IOS",
    "PTO-BLOCK-B-IOT"
  ],
  "resolves": [],
  "supersedes": [
    "ADR-GOV-0006"
  ],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "not-required",
  "legacy_ids": [
    "PRD-018",
    "PRD-019",
    "PRD-020",
    "PRD-021",
    "PRD-022",
    "PRD-023",
    "PRD-024",
    "PRD-025",
    "PRD-026",
    "PRD-027",
    "PRD-028",
    "PRD-029",
    "PRD-030",
    "ADR-0076"
  ]
}
---
# ADR-BLOCK-0013: Block scalar and tile bindings

## Context

ADR 0062 recorded a single repository-wide mnemonic audit. This record preserves the accepted decisions for this family as one decision-scoped owner. The former identifiers remain only in `legacy_ids` and the generated ADR index; current normative meaning is owned by the affected ASL/NDF clauses.

## Decisions

## Decision 018: `B.IOR` fields name absolute GPRs and encoded zero is `zero`

Each `B.IOR` source and destination field accepts exactly the twenty-four
absolute GPR selectors `0..23`. Selectors `24..31` are reserved in `B.IOR` and
MUST reject before effects; relative queue selectors are not legal.

Encoded selector zero names the architectural zero register. Canonical assembly
and disassembly use `zero`, `sp`, `a0..a7`, `ra`, `s0..s8`, and `x0..x3` for
selectors `0..23` respectively. Numeric register names MAY be accepted as input
aliases, but canonical output MUST use those ABI names.

## Decision 019: the complete block schema determines `B.IOR` presence and arity

The effective operation schema is selected after the complete block header has
been assembled. That schema determines which of `RegSrc0..RegSrc2` and
`RegDst` are consumed. An omitted `B.IOR` supplies the operation-defined
defaults for every consumed field. An explicitly encoded zero in a consumed
field supplies the zero register and is not omission.

Fields not consumed by the selected schema MUST be encoded as zero. A nonzero
unused field MUST reject before block effects. Disassembly MUST preserve the
distinction between an omitted instruction and an explicitly encoded all-zero
`B.IOR` so that reassembly preserves the exact instruction stream.

## Decision 020: PTO blocks admit at most one `B.IOR` and permit register aliasing

A PTO block MAY contain at most one `B.IOR`. Encountering a second `B.IOR` in
the same block MUST raise Illegal Block Exception before changing pending or
architectural state, and MUST preserve the first binding.

Source selectors MAY repeat. A source and destination MAY name the same GPR.
Such aliasing does not itself make the block illegal; the selected operation
defines when inputs are read and when an output becomes visible.

## Decision 021: `B.IOR` is available to every schema that declares GPR operands

`B.IOR` is not restricted to a separated block. It MAY appear in any active
`BSTART` block whose effective operation schema declares GPR input or output
fields. If the selected schema consumes no GPR field, an omitted or explicitly
all-zero `B.IOR` supplies the default state, while any nonzero binding MUST
reject before commit.

## Decision 022: TLOAD and TSTORE assign the first two `B.IOR` sources

For `TLOAD` and `TSTORE`, `RegSrc0` supplies the per-PE global-memory base
address and `RegSrc1` supplies the row stride in bytes. Each
participating PE reads the selected selectors from its own GPR file.

When `B.IOR` is omitted, the base defaults to zero and the row stride defaults
to `ceil(resolved_columns * element_bits / 8)`, producing dense rows. An
explicitly encoded zero selector supplies a zero base or zero stride and MUST
NOT select the omission default. ADR 0074 owns the byte-address formula.

## Decision 023: `B.IOT` has exactly five Local-Tile forms

`B.IOT` has exactly the five accepted forms that bind zero, one, or two ordered
Local Tile sources and zero or one Local Tile destination. It has no Shared
destination form, no reuse field, and no legacy four-bit size field.

Each six-bit source selector names a relative Local Tile queue entry:
`0..15` select `T#1..T#16`, `16..31` select `U#1..U#16`, `32..47` select
`M#1..M#16`, and `48..63` select `N#1..N#16`. Source operands are consumed in
the encoded program order.

On a destination form, `DstTile=0..3` selects the `T`, `U`, `M`, or `N`
destination hand respectively. It does not expose a physical Tile register.
`TSize=1..7` declares 128 B through 8 KiB of capacity per participating PE;
encoded `TSize=0` is reserved on every destination form.

## Decision 024: `B.IOT.PE_MASK` is a four-PE predicate

Every four-bit `PE_MASK` value is assigned and multiple set bits are legal.
All effective Local Tile bindings in one block MUST use the same nonzero mask,
and any Local/Shared operands composed by that block MUST use the same mask.
An operation MAY impose a stricter mask requirement as part of its own schema.

`PE_MASK=0000` is a strict no-op. It MUST NOT add a binding, read a source,
allocate or rename a destination, update a descriptor, produce a fault, or
change the `B.IOT` sequence-termination state.

## Decision 025: `B.IOT.L` terminates only the binding sequence

The encoded `L` bit is the `last` marker for the current block's effective
`B.IOT` sequence. It is not a source-lifetime or source-release control.

Every block that requires an effective `B.IOT` sequence MUST contain exactly
one nonzero-mask binding with `last=1`, and that binding MUST be the final
effective `B.IOT` in the block. Ending the block without that marker, placing
another effective `B.IOT` after it, or placing more than one effective marker
MUST raise Illegal Block Exception before the offending instruction or commit
changes architectural or pending block state.

## Decision 026: `B.IOT` sources persist and destinations are renamed

Reading a Local Tile source through `B.IOT` MUST NOT modify, release, or
invalidate its payload or descriptor. Successful block completion therefore
does not imply source lifetime termination, regardless of the `last` bit.

A destination form selects a destination hand and requests a new allocation.
Hardware MUST rename that request to a Local Tile register in the selected
hand, then atomically publish the new payload and descriptor at successful
block commit. Consumers refer to the renamed result through the architectural
Local Tile queue model; they do not identify the physical allocation by
reusing the producer's `PE_MASK`.

## Decision 027: `B.IOS` binds absolute Core-private Shared registers

Each core contains one architectural bank of 256 persistent Shared Tile
registers, named `S0..S255`. All four PEs in that core observe the same bank;
another core observes a different bank. `SharedTID=0..255` is an absolute
index, so encoded zero names `S0` and does not mean omission.

`B.IOS Sx, mask=PE_MASK` is the source form and encodes `TSize=0`.
`B.IOS mask=PE_MASK, ->Sx<TSize>` is the destination form and requires
`TSize=1..7`, encoding 128 B through 8 KiB per participating PE. The role
encoded by `TSize` MUST agree with the selected operation schema.

## Decision 028: `B.IOS` uses an ordered four-entry binding stream

One effective `B.IOS` adds one ordered Shared operand binding. A block MAY
contain at most four effective Shared bindings. Two unconsumed bindings in the
same block MUST NOT name the same `Sx`; a duplicate or fifth effective binding
MUST raise Illegal Block Exception before changing the binding stream or other
pending state.

`PE_MASK` is a four-PE predicate and multiple bits are legal. Every effective
Shared binding and every composed Local binding in one block MUST use the same
nonzero mask unless the selected operation defines a stricter rule.
`PE_MASK=0000` is a strict no-op: it adds no binding, performs no schema or
duplicate check, reads no source, allocates nothing, updates no descriptor,
accesses no memory, and produces no fault.

## Decision 029: Shared destinations atomically update persistent state

Each allocated `Sx` retains one per-PE Tile descriptor, a fixed allocation
mask, an initialized-quarter mask, and persistent payload. The first nonzero
destination write establishes its descriptor and allocation mask. A later
destination write MAY update any subset of that allocation mask only when the
descriptor is compatible; it MUST NOT expand the mask or silently replace an
incompatible descriptor. Software MUST allocate another `Sx` for a different
mask or descriptor.

A successful Shared destination operation atomically publishes the compatible
descriptor update and every selected fixed-offset payload quarter. An observer
MUST see either the old complete state or the new complete state, never a torn
descriptor/payload update. A Shared source read does not modify the descriptor,
payload, allocation mask, or initialized mask.

The architecture imposes no ordering between conflicting accesses from
different PEs. Programs MUST avoid conflicting offsets or establish ordering
with separate synchronization mechanisms.

## Decision 030: an uninitialized Shared source reads as undefined state

Reading an `Sx` with no allocated descriptor is legal. The consumer operation
MUST derive a read-only temporary descriptor from its own completed schema,
including its data attributes, dimensions, and any Local counterpart required
by that operation. Every selected payload element is an undefined-register
value.

This read MUST NOT allocate or initialize the Shared register, write back the
temporary descriptor, update any Shared state, or raise an exception solely
because the descriptor or selected quarter was uninitialized. Reading an
allocated but uninitialized quarter follows the same undefined-register rule
for that quarter.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

Complete Bundle operations consume scalar, Local Tile, and Shared Tile operands through different binding streams. A closed contract is required to prevent operand-order ambiguity, accidental state initialization, and inconsistent alias or lifetime behavior.

完整 Bundle 操作通过不同绑定流消费标量、Local Tile 和 Shared Tile 操作数。必须闭合契约，才能避免操作数顺序歧义、意外状态初始化以及别名或生命周期不一致。

### Detailed decision / 详细决策

`B.IOR` binds schema-declared absolute GPRs; `B.IOT` provides an ordered Local Tile stream with persistent sources and renamed destinations; `B.IOS` provides an ordered Shared stream over absolute Core-private IDs. The decisions define PE masks, sequence termination, capacity and role ownership, atomic Shared destination updates, and undefined reads without implicit allocation.

`B.IOR` 绑定模式声明的绝对 GPR；`B.IOT` 提供有序 Local Tile 流，源保持持久、目的执行重命名；`B.IOS` 以绝对 Core-private ID 提供有序 Shared 流。相关决策定义 PE 掩码、序列终止、容量与角色归属、Shared 目的原子更新，以及不触发隐式分配的未定义读取。

### What changed / 改动内容

#### English

- Assigned non-overlapping ownership to scalar, Local Tile, and Shared binding streams.
- Closed ordering, aliasing, persistence, allocation, undefined-read, and atomic-publication rules.

#### 中文

- 为标量、Local Tile 和 Shared 绑定流分配互不重叠的归属。
- 闭合顺序、别名、持久性、分配、未定义读取和原子发布规则。

### Scope and boundaries / 范围与边界

This ADR defines operand transport and binding lifecycle. Individual operations still own their required arity, types, shapes, and result semantics through the affected ASL/NDF units.

本 ADR 定义操作数传递与绑定生命周期。各操作仍通过受影响的 ASL/NDF 单元管理其所需元数、类型、形状和结果语义。
