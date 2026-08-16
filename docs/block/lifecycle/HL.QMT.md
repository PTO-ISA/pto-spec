<!-- GENERATED FROM: asl/block/lifecycle/HL.QMT.asl -->
# HL.QMT

**Normative ASL source:** `asl/block/lifecycle/HL.QMT.asl`

Queries, initializes, notifies, suspends, or restores one General Queue Management queue.

## Normative identity {#PTO-INST-BLOCK-HL-QMT}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
hl.qmt SrcL, ->RegDst
hl.qmt.e SrcL, ->RegDst
hl.qmt.s SrcL, ->RegDst
hl.qmt.r SrcL, ->RegDst
hl.qmt.es SrcL, ->RegDst
hl.qmt.er SrcL, ->RegDst
hl.qmt.i SrcL, SrcR, ->RegDst
hl.qmt.ie SrcL, SrcR, ->RegDst
hl.qmt.is SrcL, SrcR, ->RegDst
hl.qmt.ir SrcL, SrcR, ->RegDst
hl.qmt.ies SrcL, SrcR, ->RegDst
hl.qmt.ier SrcL, SrcR, ->RegDst
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_qmt_48_eb9e41958045 | HL48 | 48 | 0x0000007d000e / 0xe000707fffff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_qmt_48_eb9e41958045 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_qmt_48_eb9e41958045 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_qmt_48_eb9e41958045 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_qmt_48_eb9e41958045 | e | 1 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":1}] |
| hl_qmt_48_eb9e41958045 | i | 1 | encoding-defined | [{"instruction_lsb":44,"value_lsb":0,"width":1}] |
| hl_qmt_48_eb9e41958045 | r | 1 | encoding-defined | [{"instruction_lsb":42,"value_lsb":0,"width":1}] |
| hl_qmt_48_eb9e41958045 | s | 1 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_qmt_48_eb9e41958045 | RegDst | 5 | 0–31 | none | none | Reg5 destination for the operation result | Encoded zero names R0; reads produce zero and writes are discarded. |
| hl_qmt_48_eb9e41958045 | SrcL | 5 | 0–31 | none | none | Reg5 source of the queue address | Encoded zero names R0; reads produce zero and writes are discarded. |
| hl_qmt_48_eb9e41958045 | SrcR | 5 | 0–31 | none | none | Reg5 capacity source, read only when i=1 | Encoded zero names R0; reads produce zero and writes are discarded. |
| hl_qmt_48_eb9e41958045 | e | 1 | 0–1 | none | none | post-primary-operation event selector | Zero suppresses event notification. |
| hl_qmt_48_eb9e41958045 | i | 1 | 0–1 | none | none | initialize-or-replace selector | Zero selects query rather than initialization. |
| hl_qmt_48_eb9e41958045 | r | 1 | 0–1 | none | none | post-event restore selector | Zero suppresses restoration. |
| hl_qmt_48_eb9e41958045 | s | 1 | 0–1 | none | none | post-event suspend selector | Zero suppresses suspension. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source of the queue address |
| SrcR | Reg5 capacity source, read only when i=1 |
| RegDst | Reg5 destination for the operation result |
| i | initialize-or-replace selector |
| e | post-primary-operation event selector |
| s | post-event suspend selector |
| r | post-event restore selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/lifecycle/HL.QMT.asl -->
```asl
readonly func InstructionContractMatches_HL_QMT(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_hl_qmt_48_eb9e41958045);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/lifecycle/HL.QMT.asl -->
```asl
readonly func InstructionContractHandler_HL_QMT() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteQueueMove;
end;

func ExecuteHLQMT(destination: Reg5Selector,
                  address: Word,
                  capacity_source: Word,
                  flags: bits(4))
begin
    ExecuteQueueManagerMove(
        destination,
        address,
        capacity_source,
        flags);
end;

pure func InstructionContractChangesQueueManagerState_HL_QMT()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSnapshotsSourcesBeforeWrite_HL_QMT()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The bare form clears i, e, s, and r and queries the remaining number of 64-bit entries.
- When i=0, the encoded SrcR field is ignored and is not read; canonical assembly omits it.
- When i=1, SrcR[9:0] supplies capacity 0..1023 and higher source bits are ignored.

## Legality

- Reg5 values 0..23 select absolute R0..R23 and 24..31 select the block-relative T#1..T#4 or U#1..U#4 entries; unavailable relative sources and invalid relative destinations reject before queue state changes.
- Every flag combination is assigned except s+r, including combinations that also set i or e; s+r raises Fault_IllegalInstruction before operand reads or effects.
- The event suffix is e; b is not an alias.

## State effects

- i=0 reports remaining 64-bit entries; i=1 atomically creates or replaces the queue and returns allocated bytes.
- A successful initialization clears prior entries, corruption, and suspension. Zero capacity creates a valid empty writable queue.
- Result bits [12:0] hold the primary value and [63:62] hold status; unused bits are zero. Status 0 is success, status 1 is missing/corrupt runtime state, and 2..3 are reserved.

## Memory effects and ordering

### Memory effects

- No direct memory access. Non-relaxed queue operations carry only the GQM ordering edges defined by push and pop.

### Ordering

- For a valid queue, the primary query or initialization occurs first, then e notification, then s suspension or r restoration.
- Initialization replacement, optional event/state action, and result publication form one instruction effect.

## Exceptions

- s+r and selector failures raise Fault_IllegalInstruction before source reads, queue observation, events, destination writes, or TPC advance.
- Missing, corrupt, suspend, and restore runtime conditions are reported only in the result status and do not trap.

## Examples

- hl.qmt a0, ->a1
- hl.qmt.ie t#1, u#1, ->t#2
- hl.qmt.s sp, ->u#1

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
