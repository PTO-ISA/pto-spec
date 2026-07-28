# PTO architecture boundary

PTO is a 64-bit scalar, block/command, and tile instruction set. The ASL files
and machine-readable catalogs in this repository are the normative definition of
the architecture. They define accepted encodings, architectural state, legality,
faults, completion, ordering, and the active `pto-v0` profile.

PTO does not define vector instructions. Encodings and block forms that exist
only to host vector execution are outside the accepted PTO ISA surface.

## Accepted instruction surface

| Surface | Count | Scope |
| --- | ---: | --- |
| Scalar forms | 474 | AGU, ALU, AMO, BRU, FSU, and SYS |
| Block/command forms | 107 | block start, split, argument, dimension, control, data, IO, hint, stop, and context forms |
| Direct tile operations | 120 | 98 TEPL, 9 TMA, and 13 CUBE operations |
| System registers | 54 | base, context, translation, interrupt, and debug registers |

Exact masks, matches, operand pieces, signedness, selector values, and
constraints live in `spec/catalog/`. Generated ASL decoders bind those catalog
entries to typed operands and semantic handlers.

## Scalar state

- XLEN is 64.
- The five-bit scalar register namespace has 32 codes. R0..R23 are absolute
  GPRs and R0 is hardwired to zero. The remaining eight codes address the
  temporary result queues T#1..T#4 and U#1..U#4.
- ABI aliases are sp=R1, a0..a7=R2..R9, ra=R10,
  s0/fp..s8=R11..R19, x0..x3=R20..R23.
- Reg5 source selectors 24..27 read T#1..T#4; selectors 28..31 read U#1..U#4.
  Queue entry `#1` is newest and `#4` is oldest.
- Reg5 destinations 1..23 write GPRs; 0 and 24..29 discard the value; selector
  30 pushes U and selector 31 pushes T. A push shifts older entries toward
  `#4` and discards the previous `#4`.
- P0..P7 are 64-bit predicate registers. Scalar B.Z and B.NZ read the block
  condition outside a block body and P0 as the EXEC predicate inside a block
  body.
- Access-control state is ACR0..ACR15. PTO v0 resets to ACR0; the exact reset
  and access policy are defined by `docs/profile-contracts.md`.

## Block state

Block execution is architectural state, not a hidden backend queue. PTO exposes:

- TPC, the current scalar instruction pointer;
- BPC, the current block-body pointer;
- block active and block-body-active flags;
- block condition and commit argument state;
- block arguments, dimensions, scalar IO bindings, tile IO bindings, control
  attributes, and data attributes.

Block/command forms configure or transfer this state explicitly. A block start
checks its target and descriptor before updating block state. Block stop and
transfer forms commit or clear the visible block state through ASL-defined
state transitions. Vector-only block and queue forms are rejected by the PTO
catalog because PTO has no vector instruction execution surface.

## Tile state

- Six-bit tile indices select 64 tile registers.
- T/U/M/N hands occupy codes 0..15, 16..31, 32..47, and 48..63.
- Each register has a `TileInfo` record containing allocation, capacity, shape,
  valid region, data type, layout, location intent, and definedness.
- A normal active tile has at least 256 bytes and cannot exceed the read-only
  `TILE_CAPACITY` system register. The sum of active capacities must also stay
  within `TILE_CAPACITY`. PTO v0 resets it to 512 KiB.
- Allocation or reconfiguration makes tile contents undefined. A source read
  is illegal until an architectural write defines the contents.
- Implementations may configure `TileLayout_ImplementationDefined`. Generic
  row/column indexing rejects that layout; only a profile-specific operation
  that defines its mapping may access it.
- Elements outside the valid region are not architecturally observable unless
  an instruction explicitly defines them.
- Source operands are snapshotted before destination writes, defining
  read-before-write behavior for permitted aliases.

The ASL payload array is bounded by `PTO_MODEL_TILE_ELEMENTS` for executable
verification. Descriptor capacity defines architectural legality; the ASL array
bound is not an architectural shape limit.

## Direct tile families

- TEPL contains 98 accepted element, reduction, expansion, layout, management,
  and utility operations.
- TMA contains 9 accepted tile memory operations, including load, store, move,
  prefetch, gather, scatter, masked gather/scatter, and gather-CAS forms.
- CUBE contains 13 accepted matrix operations, including base, bias,
  accumulate, MX, ACCCVT, and matrix/vector variants.

The canonical selector and descriptor fields define encoding and operand facts.
Direct PTO tile operations have explicit destinations, sources, dimensions,
addresses, and attributes. Pipe state is not architectural.

`ExecuteTileInstruction` is the decoded tile execution boundary. The normative
tile catalog binds each accepted selector to a typed subset of
`TileInstructionOperands`, an ordered semantic-handler argument list, and an
optional scalar result. Unknown family-selector combinations raise
`Fault_IllegalInstruction` and perform no tile semantic-handler call.

Before a recognized tile operation executes, its complete operand set passes a
read-only legality predicate. Descriptor availability, logical shapes, data
types, divisor values, index ranges, and matrix/broadcast dimensions are
checked as applicable. Failure raises `Fault_TileLegality`, reports the current
TPC, returns `TileExecution_Rejected`, and performs no destination or memory
effect.

## Memory, faults, and ordering

- Byte order is little-endian.
- Scalar and tile memory share one architectural ordering domain.
- PTO-TSO defines candidate events, reads-from, coherence, from-read,
  preserved program order, acquire/release, and fence rules in
  `docs/memory-model.md`.
- Atomic `aq` and `rl` bits map to relaxed, acquire, release, or
  acquire-release ordering.
- LR/SC reservations are tracked at a 64-byte granule. An overlapping store or
  data/instruction fence invalidates the reservation.
- Misalignment, translation, permission, and restart behavior are visible. PTO
  v0 uses identity translation, a protected application region for ACR2 through
  ACR15, and full bounded-memory access for ACR0 and ACR1.
- The bounded ASL byte array is executable-test infrastructure, not the
  architectural address-space size.

Every retained data access first produces a profile-backed probe containing its
translated address or architectural fault. Multi-access scalar and tile memory
instructions probe their complete ordered access set before the first register,
tile, memory, writeback, or reservation effect. The first failing original
address is reported, and a fault commits none of the instruction's accesses.

The 32-bit encoding `0x0000700B` is the accepted DMA form. It copies 64 bytes
from the source address to the destination address with source snapshot
semantics. Destination faults are reported before any destination byte is
written.

## Scalar execution

Exact scalar form recognition and operand extraction are generated from the
normative catalog. Split fields are reconstructed into contiguous values;
signedness remains explicit metadata so instruction semantics, not the decoder,
controls extension and scaling.

`ExecuteScalarInstruction` is the decoded scalar execution boundary. Unknown or
illegal encodings raise `Fault_IllegalInstruction`. The accepted scalar forms
execute checked-in state transitions under the active profile.

Scalar floating-point values occupy the shared Reg5 carrier. Source type `00`
selects a 64-bit carrier and `01` selects a zero-extended 32-bit carrier; the
other source encodings are illegal. CORE_STATE[39:37] supplies the rounding
mode; CORE_STATE bits 32 through 36 accumulate sticky NV, DZ, OF, UF, and NX
flags. PTO v0 supplies deterministic raw-carrier numeric behavior; alternate
numeric profiles require a distinct profile identity and evidence.

## System registers

TIME and CYCLE expose one modulo-64-bit counter. Each decoded scalar, block, or
tile execution attempt advances it once, including rejected or faulting
attempts. Reset sets it to zero.

The 54-register catalog is visible through the architectural system-register
read/write interface. Base state includes THREAD_PTR, GLOBAL_PTR, BLOCKID,
THREAD_ID, CORE_STATE, CORE_ID, and TILE_CAPACITY. Context-family addresses
expose ACR trap and control state. Trap status and argument state are banked by
ACR; a fault or interrupt updates the active ring's bank.

## Excluded implementation detail

Physical tile addresses, allocation algorithms, pipelines, event IDs, backend
intrinsics, latency, throughput, target scheduling, and cost models are outside
the portable ASL contract. Target differences belong in explicit profiles, not
silent branches in portable semantics.
