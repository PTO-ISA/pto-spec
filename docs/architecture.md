# PTO architecture boundary

PTO is a 64-bit scalar and tile instruction set with one architectural execution
level. Scalar instructions, direct tile instructions, and memory operations
update a single architecture-visible state. No instruction launches another
PTO instruction body.

## Scalar state

- XLEN is 64.
- There are 24 scalar GPRs, R0..R23; R0 is hardwired to zero.
- ABI aliases are sp=R1, a0..a7=R2..R9, ra=R10,
  s0/fp..s8=R11..R19, x0..x3=R20..R23.
- Reg5 source selectors 24..27 read element (0,0) of T1..T4; selectors 28..31
  read element (0,0) of U1..U4. They are direct references to the flat tile
  register file, not additional GPRs or queue positions.
- Reg5 destinations 1..23 write GPRs, 0 and 24..29 discard the value, 30 writes
  U1 element (0,0), and 31 writes T1 element (0,0). Compressed `->t` forms use
  that same direct T1 bridge. No implicit push, pop, or body-local state exists.
- PC, return address, commit argument, predicate mask, fault code/address,
  system state, and memory-ordering state are introduced only where required by
  retained forms.
- Privilege is explicit User, Supervisor, or Machine state. PTO v0 reset enters
  Machine privilege; the exact reset and access policy is the active profile in
  `docs/profile-contracts.md`.

## Tile state

- Six-bit tile indices select 64 registers.
- T/U/M/N hands occupy codes 0..15, 16..31, 32..47, and 48..63.
- A normal active tile has 256 bytes through 256 KiB capacity; zero is the empty
  tile. Total active per-thread capacity is at most 512 KiB.
- Shape, valid region, data type, layout, and location intent are visible.
- Elements outside the valid region are not architecturally observable unless
  an instruction explicitly defines them.
- Source operands are snapshotted before destination writes, defining
  read-before-write behavior for permitted aliases.

The ASL payload array is bounded by `PTO_MODEL_TILE_ELEMENTS` for executable
verification. This is not an architectural shape limit; descriptor capacity
defines architectural legality.

## Direct tile families

- TEPL contains 97 accepted element, reduction, expansion, layout, utility, and
  pipe operations.
- TMA contains TLOAD, TSTORE, TMOV, TPREFETCH, MGATHER, and MSCATTER.
- CUBE contains TMATMUL/TGEMV base, bias, accumulate, and MX variants.

The canonical selector and descriptor fields define encoding/operand facts, not
a command queue. Direct PTO operations have explicit destinations,
sources, dimensions, addresses, and attributes.

`ExecuteTileInstruction` is the decoded tile execution boundary. The normative
tile catalog binds each accepted selector to a typed subset of
`TileInstructionOperands`, an ordered semantic-handler argument list, and an
optional result. Every one of the 111 accepted operations reaches its declared
architecture state transition. TALLOC returns its allocated address; other
accepted operations return zero. Unknown family-selector combinations raise
the illegal-instruction fault and perform no tile semantic handler call.

Before a recognized tile operation executes, its complete operand set passes a
read-only legality predicate. Descriptor availability, logical shapes, data
types, divisor values, index ranges, matrix/broadcast dimensions, and pipe
state are checked as applicable to that operation. Failure raises
`Fault_TileLegality`, reports the current PC, returns `TileExecution_Rejected`,
and performs no destination, memory, or pipe effect. Composite matrix forms
validate their bias or scale operands before the base multiply begins.

Scalar Reg5 sources 24..31 and destinations 30..31 use the same rule for their
direct T/U bridges. Decoded scalar execution preflights every explicit and
implicit bridge before its semantic handler, so an unavailable bridge raises
`Fault_TileLegality` without a partial scalar effect. The lower-level read
helper returns zero only as a defensive invariant fallback; it is not an
architectural recovery behavior.

TPREFETCH is destination-free. It performs applicable address translation,
permission, and fault checks but allocates and writes no tile. This resolves a
known independent-documentation conflict in favor of the canonical PTO contract.

## Memory and faults

- Byte order is little-endian.
- Scalar and tile memory share one architectural ordering domain.
- The memory model is PTO-TSO, with explicit candidate events, reads-from,
  coherence, from-read, preserved program order, acquire/release, and fence
  rules in `docs/memory-model.md`.
- Atomic `aq` and `rl` bits map to relaxed, acquire, release, or
  acquire-release ordering. The portable one-level address model treats FAR as
  an explicit address-class hint with identity address translation.
- Misalignment, translation, permission, and restart behavior are visible. PTO
  v0 uses identity translation, a 3072-byte User region, and full bounded-memory
  access for Supervisor and Machine.
- The bounded ASL byte array is executable-test infrastructure, not the
  architectural address-space size.

Concurrent executions are checked independently of the sequential byte-array
executor. Successful scalar and tile accesses contribute events to a common
multi-agent candidate; faulting instructions contribute none. PTO-TSO requires
acyclic per-location order and global happens-before, permits unfenced store
buffering, and forbids fenced store buffering and inconsistent message passing.
The 16-event/four-agent ASL bounds are verification limits. Mixed-size or
partially overlapping candidates fail closed until byte-level coherence is
defined. ADR-0006 records the source and ownership boundary.

Every retained data access first produces a profile-backed probe containing its
translated address or architectural fault. A scalar pair or tile memory
instruction probes its complete ordered access set before its first register,
tile, memory, writeback, or reservation effect. The first failing original
address is reported. A fault commits none of the instruction's accesses and
records no hidden progress; restart means reissuing the same instruction from
its first access after the faulting condition is removed. Single accesses use
the same probe boundary before their byte effects. The concrete translation and
permission implementation returns a stable decision for all probes within one
instruction.

DMA64 is not part of the current accepted PTO scalar surface. Its former
encoding is rejected as an illegal instruction; a future DMA contract requires
an independently specified operation, completion rule, and public source.

Exact scalar form recognition and operand extraction are generated from the
normative catalog. Split fields are reconstructed into contiguous values;
signedness remains explicit metadata so instruction semantics, not the decoder,
controls extension and scaling. Reg5 bridge behavior is defined in
`asl/scalar/operands.asl`.

Scalar catalog legality has two layers. Form constraints restrict a field
against a literal value and continue to disambiguate encoding aliases. Family
constraints select forms by semantic family, handler, and required fields, then
apply typed relations between operands. The generator emits both layers into
`ScalarFormOperandsLegal`; a failure raises `Fault_IllegalInstruction` before
Reg5 availability checks or semantic execution.

The current AGU family rules require `RegDst0` and `RegDst1` to differ whenever
a form exposes both results, and require an address-updating store's `RegDst`
to differ from `SrcD`. The comparison is between encoded selector values, not a
claim that unlike source and destination selector numbers can never address the
same backing resource. These are PTO-owned deterministic legality rules. They
do not import another ISA's constrained or implementation-selected writeback
behavior; ADR-0004 records that source boundary.

`ExecuteScalarInstruction` is the decoded scalar execution boundary. Unknown or
illegal encodings raise the illegal-instruction fault, and all 473 accepted
forms execute checked-in state transitions. `ScalarExecution_Unsupported` is
reserved for a future recognized family that lacks a completed binding; no
current catalog form returns it.

Scalar floating-point values occupy the shared Reg5 carrier. Source type `00`
selects a 64-bit carrier and `01` selects a zero-extended 32-bit carrier; the
other source encodings are illegal. CSTATE[39:37] supplies the rounding mode;
CSTATE bits 32 through 36 accumulate sticky NV, DZ, OF, UF, and NX flags,
respectively. The portable ASL fixes
ordered comparisons, signaling behavior, NaN and signed-zero min/max rules,
narrow-result packing, conversion type legality, and flag updates. Named
numeric interfaces prevent host-language behavior from leaking into the model;
PTO v0 supplies their complete deterministic raw-carrier implementation. It is
not an IEEE-754 claim. Alternate IEEE or hardware profiles require a new name
and their own conformance evidence.

TIME and CYCLE expose one modulo-64-bit counter. Each decoded scalar or tile
execution attempt advances it once, including rejected or faulting attempts.
Reset sets it to zero. Base system registers follow their catalog RO/WO/RW
class at every privilege; context, translation, interrupt, and debug families
are Machine-only in PTO v0.

## Excluded implementation detail

Physical tile addresses, allocation algorithms, pipelines, event IDs, backend
intrinsics, latency, throughput, target-specific scheduling, and cost models are
outside the portable ASL contract. A2/A3 and A5 differences belong in explicit
profiles, not silent branches in portable semantics.
