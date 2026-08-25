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

`HL.QPOP` is a standalone General Queue Management command whose queue update, status result, and optional event are one ordered instruction effect.

<!-- PTO-READER-BLOCK: block-hl-qpop-mechanism role=mechanism -->
## Placement and execution mechanism

`HL.QPOP` executes as a standalone `48`-bit command and does not require placement inside a `BSTART`/`BSTOP` body.

The accepted carrier uses the `HL48` encoding class and resolves every displayed field before the command reads bindings or changes state.

The command snapshots every required source before its first visible effect, then follows the owner-defined commit or restart boundary.

<!-- PTO-READER-BLOCK: block-hl-qpop-inputs role=inputs-outputs -->
## Carrier, bindings, and inputs

- Encoded operands: `SrcL` — Reg5 source of the queue address; `RegDst0` — Reg5 destination for popped data; `RegDst1` — Reg5 destination for the operation result; `e` — success-event selector; `r` — relaxed-ordering selector.
- All operands are resolved from the accepted carrier or named architectural state; no body-local hidden operand stream is created.
- Encoded zero remains an assigned value or a specifically documented rejection; it never silently means an omitted operand.

<!-- PTO-READER-BLOCK: block-hl-qpop-effects role=effects -->
## State effects and ordering

Source validation and snapshot precede every register, queue, frame, memory, event, or control-flow effect.

The command publishes its state and result as one ordered instruction effect, then advances or transfers control as defined by the owner.

<!-- PTO-READER-BLOCK: block-hl-qpop-constraints role=constraints -->
## Legality, faults, and atomicity

Fixed bits, reserved values, selector domains, and required Block placement are checked before architectural effects.

The current owner reports invalid schema, state, address, or continuation conditions through `Fault_IllegalInstruction`; no prose on this page creates an additional fault rule.

Rejection occurs before effects unless the current owner explicitly defines a restart boundary with retained progress; completion order remains the ASL order.

<!-- PTO-READER-BLOCK: block-hl-qpop-example role=example -->
## Non-normative worked example

This example demonstrates placement and carrier flow only; exact behavior remains in the current ASL and instruction contract.

```asm
hl.qpop a0, ->a1, a2
```

The shown accepted spelling resolves its fields from the current carrier, snapshots required sources, and then follows the owner-defined state and ordering transition.
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
