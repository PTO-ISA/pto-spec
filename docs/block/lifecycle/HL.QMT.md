<!-- GENERATED FROM: asl/block/lifecycle/HL.QMT.asl -->
# HL.QMT

**Normative ASL source:** `asl/block/lifecycle/HL.QMT.asl`

Queries, initializes, notifies, suspends, or restores one General Queue Management queue.

## Normative identity {#PTO-INST-BLOCK-HL-QMT}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-hl-qmt-purpose role=purpose -->
## What HL.QMT does

`HL.QMT` manages one General Queue Management (GQM) queue. A GQM queue holds 64-bit entries and is identified by a 64-bit address; its behavior is defined in [General queue management](../../arch/programming-model/general-queue-management.md). `HL.QMT` has one primary action and up to two follow-up actions:

- Primary: query the remaining capacity (`i=0`) or create or replace the queue (`i=1`).
- Follow-up: broadcast an event (`e`), then suspend (`s`) or restore (`r`) the queue.

[HL.QPUSH](HL.QPUSH.md) and [HL.QPOP](HL.QPOP.md) move entries through the queue.

<!-- PTO-READER-BLOCK: block-hl-qmt-mechanism role=mechanism -->
## Placement and execution mechanism

`HL.QMT` is a standalone 48-bit command. It does not open, require, or commit a block, and it advances `TPC` by 6.

After the legality checks, it reads `SrcL` as the queue address, and `SrcR` only when `i=1`. The primary action runs next. Only if it succeeds do the follow-ups run, in this order: the event if `e=1`, then suspension if `s=1` or restoration if `r=1`. Finally the result word is written to `RegDst`.

Design point: the follow-ups depend on the primary result. A query of a missing or corrupt queue fails, so `hl.qmt.s` on such a queue does not suspend anything and broadcasts no event. Initialization always succeeds, so `hl.qmt.ie` always broadcasts.

<!-- PTO-READER-BLOCK: block-hl-qmt-inputs role=inputs-outputs -->
## Carrier, bindings, and inputs

- `RegDst`, bits `27:23`: destination for the result word.
- `SrcL`, bits `35:31`: source of the queue address.
- `SrcR`, bits `40:36`: capacity source, read only when `i=1`. Bits `9:0` give a capacity of 0 to 1023 entries; higher bits are ignored.
- `e` (bit 41), `r` (bit 42), `s` (bit 43), `i` (bit 44): the action flags. The assembly suffix lists the set flags, for example `.ie`.

Each register field is a Reg5 selector, described in [scalar operands](../../scalar/model/types/operands.md). Codes 0 to 23 name R0 to R23. As sources, codes 24 to 27 read `T#1` to `T#4` and codes 28 to 31 read `U#1` to `U#4`. As a destination, code 30 pushes to the U queue, code 31 pushes to the T queue, and codes 24 to 29 discard the result.

Design point: when `i=0`, `SrcR` is neither read nor checked, and canonical assembly omits it. The bare `hl.qmt` clears all four flags and is a plain query. Encoded zero in `e`, `s`, or `r` suppresses that follow-up, and `i=0` selects the query, while encoded zero in a register field names R0, which reads zero and discards writes.

<!-- PTO-READER-BLOCK: block-hl-qmt-effects role=effects -->
## State effects and ordering

- Query (`i=0`) of a valid, uncorrupted queue returns the remaining capacity in 64-bit entries with status `00`. A missing or corrupt queue returns status `01`.
- Initialization (`i=1`) creates the queue at that address, or replaces the existing one, and returns the allocated byte count, `capacity * 8`, with status `00`. It clears prior entries, corruption, and suspension. A capacity of 0 creates a valid, empty queue.

The result word holds the primary value in bits `12:0` and the status in bits `63:62`; other bits are zero. Status 2 and 3 are reserved for `HL.QMT`.

`HL.QMT` makes no direct memory access. The primary action, follow-ups, and result write form one instruction effect.

<!-- PTO-READER-BLOCK: block-hl-qmt-constraints role=constraints -->
## Legality, faults, and atomicity

- Setting both `s` and `r` raises `Fault_IllegalInstruction`. Every other flag combination is assigned, including those with `i` or `e`.
- A relative `SrcL` source whose queue entry is not valid raises `Fault_IllegalInstruction`. With `i=1`, the same check applies to `SrcR`.
- These faults occur before source reads, queue observation, events, destination writes, or `TPC` advance.

Design point: a missing or corrupt queue is a runtime condition, not a fault. It is reported in the status bits, so software can test the result instead of taking a trap. The suffix for the event flag is `e`; `b` is not an alias.

<!-- PTO-READER-BLOCK: block-hl-qmt-example role=example -->
## Non-normative worked example

This example demonstrates placement and carrier flow only; exact behavior remains in the current ASL and instruction contract.

```asm
hl.qmt a0, ->a1
```

Suppose `a0` holds a queue address and `a2` holds 16. `hl.qmt.i a0, a2, ->a1` creates a 16-entry queue and writes `a1 = 128` (16 entries of 8 bytes) with status `00`. After three pushes, the bare query `hl.qmt a0, ->a1` writes `a1 = 13`. If `a0` named no queue, the query would write status `01` in bits `63:62` and zero in bits `12:0`, without a fault.
<!-- SUPPLEMENTARY-END -->

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
