# B.DATR

Latches tile layout, data type, padding, conversion, rounding, and saturation attributes.

<!-- ASL-SOURCE: asl/block/attributes/B.DATR.asl -->

## Assembly

```asm
B.DATR {layout, datatype, padvalue_or_byteid, cmode, rmode, sat, canonicalize}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/attributes/B.DATR.asl -->
```asl
readonly func InstructionContractMatches_B_DATR(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_b_datr_32_c161a042ff38);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/attributes/B.DATR.asl -->
```asl
readonly func InstructionContractHandler_B_DATR() => CommandSemanticHandler
begin
    return CommandHandler_SetBundleDataAttributes;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
