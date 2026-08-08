<!-- GENERATED FROM: asl/block/lifecycle/HL.QMT.asl -->
# HL.QMT

**Normative ASL source:** `asl/block/lifecycle/HL.QMT.asl`

Moves values between scalar temporary queues according to encoded queue controls.

## Normative identity {#PTO-INST-BLOCK-HL-QMT}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
hl.qmt.{i,e,s,r,ie,is,ir,es,er,ies,ier} SrcL, SrcR, ->{t, u}
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

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | encoded operand or control |
| SrcL | encoded operand or control |
| SrcR | encoded operand or control |
| e | encoded operand or control |
| i | encoded operand or control |
| r | encoded operand or control |
| s | encoded operand or control |

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
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `Moves values between scalar temporary queues according to encoded queue controls.`
- **Semantic handler:** `ExecuteQueueMove`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
