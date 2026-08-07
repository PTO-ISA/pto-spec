# C.B.DIMI

Writes one of the three bundle-local dimension registers.

<!-- ASL-SOURCE: asl/block/attributes/C.B.DIMI.asl -->

## Assembly

```asm
C.B.DIMI imm, ->{LB0, LB1, LB2}
```

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
