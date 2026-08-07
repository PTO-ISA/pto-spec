# B.IOT

Binds v5 PE_MASK, ordered Local tile sources, last-use, and optional TSize/2-bit Local destination metadata; reuse bits do not exist.

<!-- ASL-SOURCE: asl/block/operands/B.IOT.asl -->

## Assembly

```asm
B.IOT SrcTile0, mask=PE_MASK, <last>, ->DstTile<TSize>
B.IOT SrcTile0, SrcTile1, mask=PE_MASK, <last>
B.IOT SrcTile0, SrcTile1, mask=PE_MASK, <last>, ->DstTile<TSize>
B.IOT SrcTile0, mask=PE_MASK, <last>
B.IOT mask=PE_MASK, <last>, ->DstTile<TSize>
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/operands/B.IOT.asl -->
```asl
readonly func InstructionContractMatches_B_IOT(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_b_iot_32_10db6db84f5d) ||
           (operation == CommandOperation_b_iot_32_2c07e7177fad) ||
           (operation == CommandOperation_b_iot_32_8b8bce6bffe8) ||
           (operation == CommandOperation_b_iot_32_c11eb189dd83) ||
           (operation == CommandOperation_b_iot_32_efa0fe3fe49a);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/operands/B.IOT.asl -->
```asl
readonly func InstructionContractHandler_B_IOT() => CommandSemanticHandler
begin
    return CommandHandler_BindBundleTileIO;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
