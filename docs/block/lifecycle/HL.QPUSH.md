<!-- GENERATED FROM: asl/block/lifecycle/HL.QPUSH.asl -->
# HL.QPUSH

**Normative ASL source:** `asl/block/lifecycle/HL.QPUSH.asl`

Atomically pushes one 64-bit entry at the tail or head of a General Queue Management queue.

## Normative identity {#PTO-INST-BLOCK-HL-QPUSH}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

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

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
