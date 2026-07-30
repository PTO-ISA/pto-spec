# PTO architecture boundary

PTO is a 64-bit scalar, bundle/command, and tile instruction set. The ASL files
and machine-readable catalogs in this repository are the normative definition of
the architecture. They define accepted encodings, architectural state, legality,
faults, completion, ordering, and the active `pto-v0` profile.

PTO does not define vector instructions. Encodings and bundle forms that exist
only to host vector execution are outside the accepted PTO ISA surface.

## Accepted instruction surface

| Surface | Count | Scope |
| --- | ---: | --- |
| Scalar forms | 474 | AGU, ALU, AMO, BRU, FSU, and SYS |
| Bundle/command forms | 107 | bundle start, split, argument, dimension, control, data, IO, hint, stop, and context forms |
| Direct tile operations | 120 | 98 TEPL, 9 TMA, and 13 CUBE operations |
| System registers | 72 | base, context, trap snapshot, translation, interrupt, and debug registers |

Exact masks, matches, operand pieces, signedness, selector values, and
constraints live in `spec/catalog/`. Generated ASL decoders bind those catalog
entries to typed operands and semantic handlers.

## Bundle and core-block terminology

Bundle is PTO's architecture term for the visible grouped-execution unit. The
`B` prefix in `BSTART`, `BSTOP`, `C.BSTART`, `C.BSTOP`, and `B.*` means bundle,
and BPC is the bundle-body program counter.

A virtual core block is a separate topology concept. The `BLOCKNUM` and
`BLOCKID` system registers describe virtual core-block topology, and `BID` in
the encoded `CROSS_BID` field means core-block identifier. These names do not
refer to bundle state.

These spellings are stable parts of the ISA. Naming the architecture concept a
bundle does not change any instruction encoding, operand field, system-register
address, or state-transition rule.

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
- P0..P7 are 64-bit predicate registers. Scalar B.Z and B.NZ read the bundle
  condition outside a bundle body and P0 as the EXEC predicate inside a bundle
  body.
- Bundle-body entry initializes P0 to all ones. P1..P7 are trap-preserved,
  resettable visible state with no PTO v0 instruction producer or consumer;
  their selector space remains reserved pending an explicit architecture
  extension.
- Access-control state is ACR0..ACR15. PTO v0 resets to ACR0; the exact reset
  and access policy are defined by `docs/profile-contracts.md`.
- PTO v0 treats ACR0 as the root manager, ACR1 as the system manager, and
  ACR2..ACR15 as managed rings. Synchronous faults and interrupts remain in
  ACR0 or ACR1 when sourced there and route from ACR2..ACR15 to ACR1.

## Bundle state

Bundle execution is architectural state, not a hidden backend queue. PTO exposes:

- TPC, the current scalar instruction pointer;
- BPC, the current bundle-body program counter;
- bundle active and bundle-body-active flags;
- bundle condition and commit argument state;
- the exact bundle-start form, operation class, selector, DataType, Mode, and
  compressed BrType presence and values;
- bundle arguments, dimensions, scalar IO bindings, tile IO bindings, control
  attributes, and data attributes.

Bundle/command forms configure or transfer this state explicitly. A bundle start
checks its target and descriptor before updating bundle state or committing an
existing bundle. It records the pending transfer and advances through header
commands sequentially. BSTOP or the next BSTART validates the final bindings,
executes exactly one selected direct tile operation when present, and then
commits the transfer. Failed descriptor, binding, type, or tile-legality checks
preserve tile destinations and save the live bundle state in the trap context.
The exact selector, DataType, BrType, direct B.IOT boundary, and unsupported
families are defined by ADR 0022. Vector-only bundle and queue forms are rejected
by the PTO catalog because PTO has no vector instruction execution surface.

## Tile state

- Six-bit tile indices select 64 tile registers.
- T/U/M/N hands occupy codes 0..15, 16..31, 32..47, and 48..63.
- Each register has a `TileInfo` record containing allocation, capacity, shape,
  valid region, data type, layout, location intent, and definedness.
- A normal active tile has at least 256 bytes and cannot exceed the read-only
  `TILE_CAPACITY` system register. The sum of active capacities must also stay
  within `TILE_CAPACITY`. PTO v0 resets it to 512 KiB.
- Descriptor storage is `ceil(rows * columns * element_bits / 8)` bytes and
  must fit in the tile's capacity. FP4, FPL4, S4, and U4 occupy four bits per
  element for capacity accounting; an odd final element rounds up to one byte.
- Allocation has positive shape dimensions and nonzero capacity. Release is a
  distinct transition rather than a zero-capacity allocation. Reconfiguration
  replaces the destination's old contribution when checking aggregate
  capacity, and a failed check preserves the old descriptor and payload.
- Allocation or reconfiguration makes every tile element undefined. An
  element write defines only that element; whole-region consumers are illegal
  until every element of the valid region is defined. Operations that replace
  the whole valid region define it atomically after their payload effects, and
  partial updates require the preserved region to be defined first.
- Implementations may configure `TileLayout_ImplementationDefined`. Generic
  row/column indexing rejects that layout; only a profile-specific operation
  that defines its mapping may access it.
- Elements outside the valid region are not architecturally observable unless
  an instruction explicitly defines and addresses them. Their definedness is
  tracked independently and does not satisfy the valid-region summary.
- Source operands are snapshotted before destination writes, defining
  read-before-write behavior for permitted aliases.

Tile management uses explicit tile indices rather than hidden pipe state.
`TPUSH destination, source` publishes a defined source into a free destination
slot and preserves the producer. `TPOP destination, source` copies a defined
source slot into a matching configured consumer, preserves the consumer
descriptor, and releases the source slot. `TFREE` releases an allocated index;
double-free is illegal. Different slot indices have no implicit FIFO order:
their operands and architectural program order select the handoff sequence.

The ASL payload array is bounded by `PTO_MODEL_TILE_ELEMENTS` for executable
verification. Descriptor capacity defines architectural legality; the ASL array
bound is not an architectural shape limit. Packed capacity accounting does not
by itself define the address and packing protocol of sub-byte TMA transfers.

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

Numeric format codes are namespace-local, not one shared enumeration. Scalar
2-bit source types, scalar 5-bit floating destinations, scalar 5-bit integer
destinations, 6-bit TMA/TALLOC types, and 5-bit bundle `DataType` fields are
decoded independently; equal integers do not imply equal types. ADR 0040 and
`spec/evidence/numeric-format-namespace-contract.json` define every mapped and
reserved code, all 19 `TileDataType` raw-carrier widths, and low-nibble-first
packing for FP4, FPL4, S4, and U4. Exact floating meanings and target-specific
operation/type availability remain profile decisions under `S5-T2`.

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

## Instruction-attempt status

Scalar, bundle/command, direct tile, and unified dispatch use one two-outcome
execution contract. `Executed` means the attempt completed without a
synchronous architectural fault. `Rejected` means the attempt raised one,
including illegal encodings or operands, legality failures, explicit traps, and
runtime access faults.

Each public decoded boundary begins a fresh attempt by clearing only the
transient last-fault code and fault address, then advancing architectural time
once. It does not clear the current ACR trap bank or saved context. A valid trap
handler instruction can therefore execute without inheriting the prior fault
result while the manager-visible trap record remains available. Internal tile
execution during bundle commit inherits the command attempt and does not add a
second tick. ADR 0023 defines this boundary and the distinction from the
explicit `ClearFault()` state transition.

## Memory, faults, and ordering

- Byte order is little-endian.
- Scalar and tile memory share one architectural ordering domain.
- PTO-TSO defines candidate events, reads-from, coherence, from-read,
  preserved program order, acquire/release, and fence rules in
  `docs/memory-model.md`.
- Atomic `aq` and `rl` bits map to relaxed, acquire, release, or
  acquire-release ordering.
- LR/SC reservations are tracked at a 64-byte granule. Same-line SC may use a
  different byte address or width. An overlapping store, SC attempt, or data/
  instruction fence invalidates the reservation; a failed reservation check
  performs no data-access probe.
- Failed CAS remains an ordered atomic read but contributes no coherence write.
- Scalar prefetch is non-faulting and event-free. Its five-bit `model` field is
  legal no-effect hint metadata in PTO v0, and address-returning forms publish
  only the modulo-64-bit formed address. Tile `TPREFETCH` deliberately
  preflights, faults, restarts, and contributes byte reads over its footprint.
- Bounded production-event capture selects a verification agent and records
  translated locations. It is disabled during ordinary execution and cannot
  impose an architectural event-count limit.
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

Decoded-effect maturity is tracked by stable form ID in
`spec/evidence/scalar-effect-closure.json`; a form enters a closed class only
when an executable witness checks operands and before/after architectural state.
The closed ALU slice contains all 107 ALU forms, partitioned into binary,
arithmetic, pair-result, bitfield, materialization, select, and control effect
classes. `C.SETRET` is deliberately a control effect: its unsigned immediate is
doubled and added to the pre-increment TPC, and the result updates both the
bundle return address and R10.

The Stage 4-closed AGU slice contains all 183 AGU forms. Its 1,464 decoded
totality cases cover immediate limits, register modifiers, shift limits, all
encoded prefetch-model values, modulo address wrap, alignment/page/permission
precedence, pair preflight, invalid-address prefetch, and full reissue after a
fault. Another 4,296 decoded cases cover every T/U source selector, every
ordinary-zero/discard/queue-push destination class, pair destination order,
and pair-store source snapshots. The retained 183 nominal and 177 fault cases
bring the executable AGU package to 6,120 cases. ADR 0029 owns modulo-64-bit
addressing, TPC alignment, success-only update, transactional pairs,
non-faulting prefetch, exact Reg5 ordering, and restart. A reviewed independent
executable ISA/model comparison corroborates the shared address rules without
overriding PTO-specific queue, event, permission, or trap behavior.

The Stage 4-closed BRU slice contains all 66 BRU forms, partitioned into
comparison, commit, conditional branch, jump, PC-relative value, and
return-address effect classes. Its 284 decoded totality cases cross condition
limits, source modifiers, immediate limits, taken/not-taken targets, fallthrough,
halfword scaling, and modulo-64-bit wrapping. Thirty-two additional decoded
obligations prove the complete Reg5 queue/alias topology, bundle versus
non-bundle predicate selection, P0 precedence and bundle preservation, the
ignored `JR.SrcZero` alias field, synchronized R10/bundle return state, and
precise odd-target faults both outside and inside a bundle. ADR 0027 defines the
portable target policy and records why a start-marker check is not part of PTO
v0.

The Stage 4-closed FSU slice contains all 30 FSU forms. Its 2,270 decoded
executions cover every legal and reserved source/destination type, FP32/FP64
raw boundary and exceptional encoding, active and fixed rounding selection,
all Reg5 source and destination classes, aliases, sticky flags, and precise
illegal-type no-effect faults. ADR 0028 defines ordered NaN comparisons,
min/max and signed-zero results, the raw format-code table, and the boundary
between deterministic PTO-v0 carrier behavior and Stage 5 target numerical
conformance.

The closed AMO reference-totality slice contains all 53 AMO forms, partitioned into load-reserved,
store-conditional, swap, compare-and-swap, load-return RMW, store-only RMW, and
DMA effects. The 66 retained Stage 1 attempts and 2,474 unique Stage 4 attempts
cover every modifier, width-specific value and conditional result, Reg5 and
ignored-field alias, fault/restart/no-probe path, reservation interaction, and
64-byte DMA overlap, boundary, fault, and restart case. ADR 0030 and
`scalar-amo-totality.json` fix the contract and keep PTO-v0 identity-translation
and shared read/write permission limits explicit. Together with the closed
Stage 3 ordering suite, this evidence closes `S4-T3` without importing the
independent comparison model as normative authority.

The closed FSU Stage 1 slice contains all 30 FSU forms in ten effect classes
that separate architecture-owned absolute, min/max, and comparison rules from
profile-dependent unary, binary, fused, and conversion behavior. Its decoded
witnesses prove the deterministic PTO-v0 raw-carrier result, width
normalization, sticky flags, rejected type encodings, TPC, status, and time.
This is not floating-point numerical closure: correctly rounded arithmetic,
single-rounding fused behavior, exceptional values, conversion saturation, and
complete NV/DZ/OF/UF/NX conformance remain Stage 4/5 work.

The closed SYS slice contains all 35 SYS forms in thirteen effect
classes covering system-register transfers, cache and TLB maintenance epochs,
execution-control requests, breakpoints, fences, ASSERT, ACRC, ACRE, and commit
target state. PTO defines `SETC.TGT` as copying the decoded source value into
the commit argument; it does not preserve the source selector identity. The
PTO-v0 cache maintenance operands are accepted as opaque scope tokens, while
their visible completion effect is the selected family epoch. TLB maintenance
is ACR0-only and validates canonical-VA48 or low-16-bit ASID operands. Control
requests are nonblocking scheduling handoffs, and ACRE request types zero and
one are aliases. ADR 0031 and 4,401 unique Stage 4 decoded cases close the SYS
reference semantics without claiming a physical cache, TLB, scheduler, MMU, or
debug matcher.

The closed AGU Stage 1 slice contains all 183 forms in eight effect classes:
single load/store with and without writeback, load/store pair, non-result
prefetch, and address-returning prefetch. Generated witnesses cover all
immediate, register, PC-relative, and compressed address kinds; pre/post-index
updates; widths and signedness; ordered memory events; pair preflight; precise
fault suppression; and non-faulting prefetch. PC-relative forms distinguish the
four-byte-aligned TPC rule, and every register `.UPR`/`.UPO` store distinguishes
its unscaled offset.

TPC names the current scalar instruction address at dispatch. After a
non-control scalar instruction completes without a fault, TPC advances by the
encoded instruction length in bytes. Relative branches and jumps compute their
next TPC from the current value, indirect jumps install their checked target,
and ACRE installs the recovered TPC. A runtime architectural fault returns
`ScalarExecution_Rejected` after trap entry; `ScalarExecution_Executed` means
that the instruction completed without a fault.

Scalar PC-relative memory forms align TPC down to a four-byte boundary before
adding their four-byte-scaled displacement. Register-offset `.UPR` and `.UPO`
store-writeback forms are explicitly unscaled: the modified offset is added
without element-size scaling. ADR 0024 records both choices and their
distinguishing decoded witnesses.

Scalar bitfield widths are encoded as `imml + 1`, while `imms` or `immr`
independently selects a wrapping start bit. `REV` reverses bytes from the
selected field into a zero-extended result and returns zero, without fault, for
a width that is not byte-aligned. `HL.BFI` inserts through the wrapping inclusive
destination interval. ADR 0025 fixes these bounds and requires source snapshot
semantics for aliases.

All scalar ALU sources are snapshotted before destination effects. Pair-result
forms write destination zero before destination one; a repeated GPR destination
therefore retains result one, while two pushes to the same T or U queue leave
result one newest and result zero next-newest. Arithmetic wraps at the selected
width, word results sign extend, shift counts use the low width-dependent bits,
and integer division is non-trapping. ADR 0026 records the complete reference
rules and the Stage 4 boundary/alias evidence contract.

Scalar floating-point values occupy the shared Reg5 carrier. Source type `00`
selects a 64-bit carrier and `01` selects a zero-extended 32-bit carrier; the
other source encodings are illegal. CORE_STATE[39:37] supplies the rounding
mode: 0 is nearest, 1 is toward negative infinity, 2 is toward positive
infinity, 3 is toward zero, and 4 is away from zero. Reserved encodings 5–7
select nearest in PTO v0. CORE_STATE bits 32 through 36 accumulate sticky NV,
DZ, OF, UF, and NX flags. PTO v0 supplies deterministic raw-carrier numeric
behavior; alternate numeric profiles require a distinct profile identity and
evidence.

## System registers

TIME and CYCLE expose one modulo-64-bit counter. Each decoded scalar, bundle, or
tile execution attempt advances it once, including rejected or faulting
attempts. Reset sets it to zero.

The 72-register catalog is visible through the architectural system-register
read/write interface. Base state includes THREAD_PTR, GLOBAL_PTR, BLOCKID,
THREAD_ID, CORE_STATE, CORE_ID, and TILE_CAPACITY. Context-family addresses
expose ACR trap and control state. Trap status and argument state are banked by
ACR; a fault or interrupt updates the selected manager's bank. Reset clears the
defined context-family range in every ACR bank. Bundle-format and bundle-control
faults report `BUNDLE_TRAP` (5); `SCALL` (6) is reserved for `ACRC` service
requests.

Every trap catalog row also fixes its producer envelope, PTO v0 trigger status,
cause, argument, and restart class. Ten identities are production-active. A
legal `ACRE` whose visible saved context cannot be recovered produces
`EXEC_STATE_CHECK`; an unsupported ACRE request encoding produces
`ILLEGAL_INST`. `INST_PAGE_FAULT`, `HW_BREAKPOINT`, and `HW_WATCHPOINT` have
complete entry and recovery envelopes but no PTO v0 production trigger;
identity translation and disabled debug matching cannot produce them. Trap zero
is distinguished from an empty bank by the trap argument-valid state.

The canonical catalog assigns every register a reset, read, write, side-effect,
and profile-status class. Generated witnesses cover every base register, every
visible ACR bank, and each fixed-context address. PTO v0 classifies translation,
`XBINFO`, `ACR_PARAM`, and debug registers as visible storage-only state:
reads and permitted writes are deterministic, but identity translation and the
disabled debug matcher do not consume their values. Activating those effects
requires a distinct profile contract rather than an implicit backing-store
interpretation.

The decoded SYS transfer matrix covers all 837 concrete bank-expanded
addresses through every encoding-width-applicable read, write, and swap form:
1,937 address/form cases plus 1,184 Reg5 selector and swap-alias cases.
`SSRSWAP` preflights read permission, write permission, and RW class before it
reads, so a rejected swap cannot refresh a read-side-effecting RO register.

Cache maintenance completes synchronously by retaining the operation and its
opaque operand and advancing the selected cache-family epoch. TLB maintenance
uses the same completion record after ACR0 privilege and operand checks.
`FENCE.D` records all predecessor/successor masks, emits the ordering event,
and invalidates the reservation; `FENCE.I` supplies the instruction-visibility
epoch and also invalidates the reservation. `BSE`, `BWE`, `BWI`, and `BWT`
retire after publishing a nonblocking scheduling request and operand; PTO-v0
defines no additional visible sleep or wake state.

`ACRC` is an immediate synchronous service request. ACR1 machine/security
requests route to ACR0. ACR2..ACR15 system requests route to ACR1 and their
machine/security requests route to ACR0. The trap reports the request in
`CAUSE`, the source TPC in `TRAPARG0`, and source TPC + 4 in `EBARG_TPC` so
ordinary recovery advances past the 32-bit ACRC.

Trap save and recovery preserve all eight predicate registers in addition to
TPC, BPC, core state, and the T/U queues. Bundle preservation includes kind,
transfer, condition, targets, fallthrough, the operation-bearing start
descriptor, dimensions, scalar/tile bindings, and control/data attributes.
Manager edits to EBARG-covered fields remain authoritative; saved context
restores fields without a visible EBARG encoding.

The 18-register `EBARG` group at low indices `0xF40` through `0xF51` exposes
first-layer trap and context words. The 13 words through `EBARG_UQ3` are
recovery-active: packed control, current and target BPC, resume TPC, local
return address, and all four T and U queue entries. PTO v0 has no first-layer
loop state, so trap save clears `EBARG_LB` and `EBARG_LC` and recovery ignores
them. `EBARG_EXTCTX_PTR`, `EBARG_EXTCTX_META`, and `EBARG_TPLFLAGS` are
persistent storage-only context words: trap save preserves them and recovery
does not consume them. An address written as `0x{n}F40` selects the bank for
ACR `n`; the ACR nibble is part of the 16-bit canonical address, not an
arithmetic offset.

The ACR interrupt registers form one visible subsystem. `IPENDING` is a 64-bit
pending-ID bitmap, `TOPEI` reports the lowest pending ID, and `EOIEI` clears the
ID it names. `ECONFIG[0]` and `[1]` enable external and timer entry. A nonzero
`TIMER_TIMECMP` asserts the bank's timer pending bit when architectural time
reaches it; acknowledgement reasserts while the comparison remains reached,
and writing a zero comparison disables the timer source.

## Excluded implementation detail

Physical tile addresses, allocation algorithms, pipelines, implicit FIFO
cursors, event IDs, backend
intrinsics, latency, throughput, target scheduling, and cost models are outside
the portable ASL contract. Target differences belong in explicit profiles, not
silent branches in portable semantics.
