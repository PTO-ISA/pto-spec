# BSTART.TGEMVMX.BIAS

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

<!-- ASL-SOURCE: asl/block/execution/BSTART.TGEMVMX.BIAS.asl -->

## Assembly

```asm
BSTART.TGEMVMX.BIAS DataType
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.TGEMVMX.BIAS.asl -->
```asl
readonly func InstructionContractMatches_BSTART_TGEMVMX_BIAS(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_tgemvmx_bias_32_d23011f15171);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.TGEMVMX.BIAS.asl -->
```asl
readonly func InstructionContractHandler_BSTART_TGEMVMX_BIAS() => CommandSemanticHandler
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
