# B.DIM

Writes one of the three bundle-local dimension registers.

<!-- ASL-SOURCE: asl/block/attributes/B.DIM.asl -->

## Assembly

```asm
B.DIM RegSrc, uimm, ->LB2
B.DIM RegSrc, uimm, ->LB0
B.DIM RegSrc, uimm, ->LB1
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/attributes/B.DIM.asl -->
```asl
readonly func InstructionContractMatches_B_DIM(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_b_dim_32_1caa1aa2944a) ||
           (operation == CommandOperation_b_dim_32_27602ab68929) ||
           (operation == CommandOperation_b_dim_32_4191099a5f4d);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/attributes/B.DIM.asl -->
```asl
readonly func InstructionContractHandler_B_DIM() => CommandSemanticHandler
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
