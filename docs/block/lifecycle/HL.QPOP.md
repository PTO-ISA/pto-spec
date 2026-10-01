<!-- GENERATED FROM: asl/block/lifecycle/HL.QPOP.asl -->
# HL.QPOP

**Normative ASL source:** `asl/block/lifecycle/HL.QPOP.asl`

Atomically pops one 64-bit head entry from a General Queue Management queue.

## Normative identity {#PTO-INST-BLOCK-HL-QPOP}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-hl-qpop-purpose role=purpose -->
## What HL.QPOP does

`HL.QPOP` removes the head entry of a General Queue Management (GQM) queue. It writes the entry to one register and a result word to a second register, and reports an empty or missing queue in that result instead of trapping. Entries arrive through [HL.QPUSH](HL.QPUSH.md); queue behavior is defined in [General queue management](../../arch/programming-model/general-queue-management.md).

<!-- PTO-READER-BLOCK: block-hl-qpop-mechanism role=mechanism -->
## Placement and execution mechanism

`HL.QPOP` is a standalone 48-bit command. It does not open, require, or commit a block, and it advances `TPC` by 6.

After the legality checks, it reads the queue address from `SrcL` and validates the queue. If there is an entry, it removes the head, broadcasts an event if `e=1`, and then writes the entry to `RegDst0` and the result word to `RegDst1`, in that order.

Design point: the two writes are ordered. If `RegDst0` and `RegDst1` name the same absolute register, it ends up holding the result word. If both push to the same relative queue, the data is pushed first and the result second.

<!-- PTO-READER-BLOCK: block-hl-qpop-inputs role=inputs-outputs -->
## Carrier, bindings, and inputs

- `RegDst1`, bits `15:11`: destination for the result word.
- `RegDst0`, bits `27:23`: destination for the popped entry.
- `SrcL`, bits `35:31`: source of the queue address.
- `e` (bit 41), `r` (bit 42): the flags. All four combinations are assigned.
- Bits `40:36` are fixed reserved-zero bits, not an operand.

Each register field is a Reg5 selector, described in [scalar operands](../../scalar/model/types/operands.md). Codes 0 to 23 name R0 to R23; as a source, codes 24 to 31 read `T#1` to `T#4` and `U#1` to `U#4`. As a destination, code 30 pushes to the U queue, code 31 pushes to the T queue, and codes 24 to 29 discard the value.

Design point: the bare form has acquire ordering and no event. `e=0` suppresses the event and `r=0` selects acquire, so an encoded zero keeps the ordered default. A destination of R0 discards its value, which lets a program pop without keeping the data.

<!-- PTO-READER-BLOCK: block-hl-qpop-effects role=effects -->
## State effects and ordering

- A successful pop removes the head entry, writes its value to `RegDst0`, and writes status `00` with the remaining entry count in bits `12:0` of `RegDst1`. It succeeds even while the queue is suspended.
- An empty queue writes status `01` and count 0; a missing or corrupt queue writes status `10` and count 0. In both cases `RegDst0` receives zero and the queue is unchanged. Status 3 is reserved.

Only a successful pop with `e=1` broadcasts an event. The queue update and both writes are one instruction effect.

Design point: with `r=0`, a successful pop is an acquire. If the entry was pushed with release ordering, the pop acquires the memory operations ordered before that push. With `r=1`, no acquire edge is recorded. `HL.QPOP` itself makes no direct memory access.

<!-- PTO-READER-BLOCK: block-hl-qpop-constraints role=constraints -->
## Legality, faults, and atomicity

- A nonzero value in bits `40:36` does not decode as `HL.QPOP` and raises `Fault_IllegalInstruction`.
- A relative `SrcL` source whose queue entry is not valid raises `Fault_IllegalInstruction`.
- Both faults occur before source reads, queue observation, events, destination writes, or `TPC` advance.

Empty, missing, and corrupt queues are reported in `RegDst1` and do not trap. The generated legality and exception sections below are authoritative.

<!-- PTO-READER-BLOCK: block-hl-qpop-example role=example -->
## Non-normative worked example

This example demonstrates placement and carrier flow only; exact behavior remains in the current ASL and instruction contract.

```asm
hl.qpop a0, ->a1, a2
```

Suppose `a0` names a queue holding `0x55` at the head and one more entry behind it. The pop writes `a1 = 0x55` and `a2` with status `00` and count 1. A second pop removes the last entry and reports count 0. A third pop finds the queue empty: `a1` receives 0 and `a2` receives status `01`, without a fault.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.qpop SrcL, ->RegDst0, RegDst1
hl.qpop.e SrcL, ->RegDst0, RegDst1
hl.qpop.r SrcL, ->RegDst0, RegDst1
hl.qpop.er SrcL, ->RegDst0, RegDst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_qpop_48_a2c57f5bc27b | HL48 | 48 | 0x0000207d000e / 0xf9f0707f07ff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_qpop_48_a2c57f5bc27b | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_qpop_48_a2c57f5bc27b | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_qpop_48_a2c57f5bc27b | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_qpop_48_a2c57f5bc27b | e | 1 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":1}] |
| hl_qpop_48_a2c57f5bc27b | r | 1 | encoding-defined | [{"instruction_lsb":42,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_qpop_48_a2c57f5bc27b | RegDst0 | 5 | 0–31 | none | none | Reg5 destination for popped data | Encoded zero names R0; reads produce zero and writes are discarded. |
| hl_qpop_48_a2c57f5bc27b | RegDst1 | 5 | 0–31 | none | none | Reg5 destination for the operation result | Encoded zero names R0; reads produce zero and writes are discarded. |
| hl_qpop_48_a2c57f5bc27b | SrcL | 5 | 0–31 | none | none | Reg5 source of the queue address | Encoded zero names R0; reads produce zero and writes are discarded. |
| hl_qpop_48_a2c57f5bc27b | e | 1 | 0–1 | none | none | success-event selector | Zero suppresses event notification. |
| hl_qpop_48_a2c57f5bc27b | r | 1 | 0–1 | none | none | relaxed-ordering selector | Zero selects acquire ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source of the queue address |
| RegDst0 | Reg5 destination for popped data |
| RegDst1 | Reg5 destination for the operation result |
| e | success-event selector |
| r | relaxed-ordering selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/lifecycle/HL.QPOP.asl -->
```asl
readonly func InstructionContractMatches_HL_QPOP(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_hl_qpop_48_a2c57f5bc27b);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/lifecycle/HL.QPOP.asl -->
```asl
readonly func InstructionContractHandler_HL_QPOP() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteQueuePop;
end;

func ExecuteHLQPOP(destination0: Reg5Selector,
                   destination1: Reg5Selector,
                   address: Word,
                   flags: bits(4))
begin
    ExecuteQueueManagerPop(
        destination0,
        destination1,
        address,
        flags);
end;

pure func InstructionContractChangesQueueManagerState_HL_QPOP()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSnapshotsSourcesBeforeWrite_HL_QPOP()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The bare form has acquire semantics and publishes no event.
- e=0 suppresses notification and r=0 selects acquire ordering.
- Bits [40:36] are fixed reserved-zero bits and are never an operand.

## Legality

- Reg5 values 0..23 select absolute R0..R23 and 24..31 select the block-relative T#1..T#4 or U#1..U#4 entries; unavailable relative sources and invalid relative destinations reject before queue state changes.
- All four e/r flag combinations are assigned.
- Any nonzero value in bits [40:36] is reserved and raises Fault_IllegalInstruction before source reads or effects.

## State effects

- A successful pop removes the head entry even while the queue is suspended, writes its value to RegDst0, and reports status zero.
- RegDst1[12:0] holds the post-attempt remaining entry count and [63:62] holds status; unused bits are zero. Status 1 is empty, 2 is missing or corrupt, and 3 is reserved.
- Only a successful pop with e=1 broadcasts an event. The queue update and both destination writes are one instruction effect.

## Memory effects and ordering

### Memory effects

- No direct memory access. A non-relaxed successful pop acquires memory operations released by the observed entry's non-relaxed push.

### Ordering

- Queue validation and data selection precede the atomic head removal. A successful removal precedes optional event notification and the ordered RegDst0 then RegDst1 writes.
- r=0 establishes the acquire edge; r=1 is relaxed and records no acquire edge. Destination aliases follow ordered multi-destination write rules.

## Exceptions

- Nonzero reserved bits [40:36] and selector failures raise Fault_IllegalInstruction before source reads, queue observation, events, destination writes, or TPC advance.
- Empty, missing, and corrupt queues report status in RegDst1 and do not trap.

## Examples

- hl.qpop a0, ->a1, a2
- hl.qpop.e t#1, ->t#2, u#1
- hl.qpop.r sp, ->zero, a0
