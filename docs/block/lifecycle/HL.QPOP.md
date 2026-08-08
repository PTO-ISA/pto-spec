<!-- GENERATED FROM: asl/block/lifecycle/HL.QPOP.asl -->
# HL.QPOP

**Normative ASL source:** `asl/block/lifecycle/HL.QPOP.asl`

Pops selected scalar queue values into encoded destinations.

## Normative identity {#PTO-INST-BLOCK-HL-QPOP}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
hl.qpop.{e,r,er} SrcL, ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_qpop_48_a2c57f5bc27b | HL48 | 48 | 0x0000207d000e / 0xf800707f07ff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_qpop_48_a2c57f5bc27b | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_qpop_48_a2c57f5bc27b | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_qpop_48_a2c57f5bc27b | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_qpop_48_a2c57f5bc27b | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_qpop_48_a2c57f5bc27b | e | 1 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":1}] |
| hl_qpop_48_a2c57f5bc27b | r | 1 | encoding-defined | [{"instruction_lsb":42,"value_lsb":0,"width":1}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/lifecycle/HL.QPOP.asl -->
```asl
readonly func InstructionContractMatches_HL_QPOP(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_hl_qpop_48_a2c57f5bc27b);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/lifecycle/HL.QPOP.asl -->
```asl
readonly func InstructionContractHandler_HL_QPOP() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteQueuePop;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
