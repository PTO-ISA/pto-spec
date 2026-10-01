<!-- GENERATED FROM: asl/block/lifecycle/HL.QPUSH.asl -->
# HL.QPUSH

**Normative ASL source:** `asl/block/lifecycle/HL.QPUSH.asl`

Atomically pushes one 64-bit entry at the tail or head of a General Queue Management queue.

## Normative identity {#PTO-INST-BLOCK-HL-QPUSH}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-hl-qpush-purpose role=purpose -->
## What HL.QPUSH does

`HL.QPUSH` adds one 64-bit entry to a General Queue Management (GQM) queue, at the tail by default or at the head with `.h`. It reports the outcome in a result register instead of trapping. Queues are created with [HL.QMT](HL.QMT.md) and drained with [HL.QPOP](HL.QPOP.md); their behavior is defined in [General queue management](../../arch/programming-model/general-queue-management.md).

<!-- PTO-READER-BLOCK: block-hl-qpush-mechanism role=mechanism -->
## Placement and execution mechanism

`HL.QPUSH` is a standalone 48-bit command. It does not open, require, or commit a block, and it advances `TPC` by 6.

After the legality checks, it reads the queue address from `SrcL` and the entry from `SrcR`. It then validates the queue. If the queue accepts the entry, the entry is inserted, the event is broadcast if `e=1`, and the result word is written to `RegDst`. Otherwise only the result word is written.

Design point: both sources are read before `RegDst` is written. A destination that names the same register as a source therefore does not change the address or entry that the push uses.

<!-- PTO-READER-BLOCK: block-hl-qpush-inputs role=inputs-outputs -->
## Carrier, bindings, and inputs

- `RegDst`, bits `27:23`: destination for the result word.
- `SrcL`, bits `35:31`: source of the queue address.
- `SrcR`, bits `40:36`: source of the 64-bit entry.
- `e` (bit 41), `r` (bit 42), `h` (bit 43): the flags. All eight combinations are assigned, spelled by the suffix, for example `.her`.

Each register field is a Reg5 selector, described in [scalar operands](../../scalar/model/types/operands.md). Codes 0 to 23 name R0 to R23. As sources, codes 24 to 31 read `T#1` to `T#4` and `U#1` to `U#4`. As a destination, code 30 pushes to the U queue, code 31 pushes to the T queue, and codes 24 to 29 discard the result.

Design point: the bare form is a tail insert with no event and release ordering. Each flag's encoded zero selects that default: `h=0` tail, `e=0` no event, `r=0` release. Setting `r` requests relaxed ordering, so the ordering edge is opt-out, not opt-in.

<!-- PTO-READER-BLOCK: block-hl-qpush-effects role=effects -->
## State effects and ordering

- A successful push stores the entry, returns the remaining capacity after the push in bits `9:0`, and writes status `00` in bits `63:62`.
- A full or suspended queue returns status `01` with the current remaining capacity; nothing is stored.
- A missing or corrupt queue returns status `10`; nothing is stored. Status 3 is reserved.

Only a successful push with `e=1` broadcasts an event. The queue update, the event, and the result write are one atomic instruction effect.

Design point: with `r=0`, a successful push is a release. The entry records a release epoch, and a non-relaxed pop that removes this entry acquires the memory operations ordered before the push. With `r=1` the entry records no release edge. `HL.QPUSH` itself makes no direct memory access.

<!-- PTO-READER-BLOCK: block-hl-qpush-constraints role=constraints -->
## Legality, faults, and atomicity

A relative `SrcL` or `SrcR` source whose queue entry is not valid raises `Fault_IllegalInstruction` before source reads, queue observation, events, destination writes, or `TPC` advance.

Full, suspended, missing, and corrupt queues are reported in `RegDst` and do not trap. A queue of capacity 0 is always full, so a push to it returns status `01`.

The event suffix is `e`; `b` is not an alias. The generated legality and exception sections below are authoritative.

<!-- PTO-READER-BLOCK: block-hl-qpush-example role=example -->
## Non-normative worked example

This example demonstrates placement and carrier flow only; exact behavior remains in the current ASL and instruction contract.

```asm
hl.qpush a0, a1, ->a2
```

Suppose `a0` names a 16-entry queue that already holds 3 entries, and `a1` holds `0x55`. The push appends `0x55` at the tail and writes `a2 = 12` with status `00`. With `hl.qpush.h`, `0x55` would be inserted before the current head instead, so the next pop returns it first. If the queue were suspended, `a2` would receive status `01` with 13 in bits `9:0`, and the queue would be unchanged.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.qpush SrcL, SrcR, ->RegDst
hl.qpush.h SrcL, SrcR, ->RegDst
hl.qpush.e SrcL, SrcR, ->RegDst
hl.qpush.r SrcL, SrcR, ->RegDst
hl.qpush.he SrcL, SrcR, ->RegDst
hl.qpush.hr SrcL, SrcR, ->RegDst
hl.qpush.er SrcL, SrcR, ->RegDst
hl.qpush.her SrcL, SrcR, ->RegDst
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_qpush_48_3eab8e05d61a | HL48 | 48 | 0x0000107d000e / 0xf000707fffff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_qpush_48_3eab8e05d61a | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_qpush_48_3eab8e05d61a | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_qpush_48_3eab8e05d61a | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_qpush_48_3eab8e05d61a | e | 1 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":1}] |
| hl_qpush_48_3eab8e05d61a | h | 1 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":1}] |
| hl_qpush_48_3eab8e05d61a | r | 1 | encoding-defined | [{"instruction_lsb":42,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_qpush_48_3eab8e05d61a | RegDst | 5 | 0–31 | none | none | Reg5 destination for the operation result | Encoded zero names R0; reads produce zero and writes are discarded. |
| hl_qpush_48_3eab8e05d61a | SrcL | 5 | 0–31 | none | none | Reg5 source of the queue address | Encoded zero names R0; reads produce zero and writes are discarded. |
| hl_qpush_48_3eab8e05d61a | SrcR | 5 | 0–31 | none | none | Reg5 source of the 64-bit entry | Encoded zero names R0; reads produce zero and writes are discarded. |
| hl_qpush_48_3eab8e05d61a | e | 1 | 0–1 | none | none | success-event selector | Zero suppresses event notification. |
| hl_qpush_48_3eab8e05d61a | h | 1 | 0–1 | none | none | head-insertion selector | Zero appends at the queue tail. |
| hl_qpush_48_3eab8e05d61a | r | 1 | 0–1 | none | none | relaxed-ordering selector | Zero selects release ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source of the queue address |
| SrcR | Reg5 source of the 64-bit entry |
| RegDst | Reg5 destination for the operation result |
| h | head-insertion selector |
| e | success-event selector |
| r | relaxed-ordering selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/lifecycle/HL.QPUSH.asl -->
```asl
readonly func InstructionContractMatches_HL_QPUSH(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_hl_qpush_48_3eab8e05d61a);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/lifecycle/HL.QPUSH.asl -->
```asl
readonly func InstructionContractHandler_HL_QPUSH() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteQueuePush;
end;

func ExecuteHLQPUSH(destination: Reg5Selector,
                    address: Word,
                    entry: Word,
                    flags: bits(4))
begin
    ExecuteQueueManagerPush(
        destination,
        address,
        entry,
        flags);
end;

pure func InstructionContractChangesQueueManagerState_HL_QPUSH()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSnapshotsSourcesBeforeWrite_HL_QPUSH()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The bare form appends at the tail, publishes no event, and has release semantics.
- h=0 selects tail insertion, e=0 suppresses notification, and r=0 selects release ordering.

## Legality

- Reg5 values 0..23 select absolute R0..R23 and 24..31 select the block-relative T#1..T#4 or U#1..U#4 entries; unavailable relative sources and invalid relative destinations reject before queue state changes.
- All eight h/e/r flag combinations are assigned; the event suffix is e and b is not an alias.

## State effects

- h=0 appends one entry at the tail; h=1 inserts one entry at the head. The queue update, optional event, and destination result are atomic.
- Result bits [9:0] hold post-push remaining capacity and [63:62] hold status; unused bits are zero. Status 0 is success, 1 is full or suspended, 2 is missing or corrupt, and 3 is reserved.
- Only a successful push with e=1 broadcasts an event.

## Memory effects and ordering

### Memory effects

- No direct memory access. A non-relaxed successful push releases memory operations ordered before it to an acquiring pop that observes the entry.

### Ordering

- Queue validation precedes insertion. A successful insertion precedes optional event notification and result publication.
- r=0 establishes the release edge; r=1 is relaxed and records no release edge.

## Exceptions

- Selector failures raise Fault_IllegalInstruction before source reads, queue observation, events, destination writes, or TPC advance.
- Full, suspended, missing, and corrupt queues report status in RegDst and do not trap.

## Examples

- hl.qpush a0, a1, ->a2
- hl.qpush.he t#1, u#1, ->t#2
- hl.qpush.r sp, zero, ->u#1
