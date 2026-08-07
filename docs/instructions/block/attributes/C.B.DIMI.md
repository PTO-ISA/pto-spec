# C.B.DIMI

Writes one of the three bundle-local dimension registers.

<!-- ASL-SOURCE: asl/block/attributes/C.B.DIMI.asl -->

## Normative identity {#PTO-INST-BLOCK-C-B-DIMI}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
C.B.DIMI imm, ->{LB0, LB1, LB2}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_b_dimi_16_3f1b113c76ce | C16 | 16 | 0x003c / 0x003f | [{"field":"LoopNest","operator":"not-equal","value":3}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_b_dimi_16_3f1b113c76ce | LoopNest | 2 | encoding-defined | [{"instruction_lsb":14,"value_lsb":0,"width":2}] |
| c_b_dimi_16_3f1b113c76ce | imm8 | 8 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":8}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/attributes/C.B.DIMI.asl -->
```asl
readonly func InstructionContractMatches_C_B_DIMI(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_c_b_dimi_16_3f1b113c76ce);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/attributes/C.B.DIMI.asl -->
```asl
readonly func InstructionContractHandler_C_B_DIMI() => CommandSemanticHandler
begin
    return CommandHandler_SetBundleDimension;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
