# BSTART.MSCATTER.MASK

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

<!-- ASL-SOURCE: asl/block/execution/BSTART.MSCATTER.MASK.asl -->

## Assembly

```asm
BSTART.MSCATTER.MASK DataType
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.MSCATTER.MASK.asl -->
```asl
readonly func InstructionContractMatches_BSTART_MSCATTER_MASK(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_mscatter_mask_32_2a33eed646f7);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.MSCATTER.MASK.asl -->
```asl
readonly func InstructionContractHandler_BSTART_MSCATTER_MASK() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
