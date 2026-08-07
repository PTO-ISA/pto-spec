# BSTART.TMATMULMX.BIAS

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

<!-- ASL-SOURCE: asl/block/execution/BSTART.TMATMULMX.BIAS.asl -->

## Assembly

```asm
BSTART.TMATMULMX.BIAS DataType
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.TMATMULMX.BIAS.asl -->
```asl
readonly func InstructionContractMatches_BSTART_TMATMULMX_BIAS(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_tmatmulmx_bias_32_098c7efa51b0);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.TMATMULMX.BIAS.asl -->
```asl
readonly func InstructionContractHandler_BSTART_TMATMULMX_BIAS() => CommandSemanticHandler
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
