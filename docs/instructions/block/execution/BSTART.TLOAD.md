# BSTART.TLOAD

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

<!-- ASL-SOURCE: asl/block/execution/BSTART.TLOAD.asl -->

## Assembly

```asm
BSTART.TLOAD DataType
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.TLOAD.asl -->
```asl
readonly func InstructionContractMatches_BSTART_TLOAD(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_tload_32_d0c18bb0ab15);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.TLOAD.asl -->
```asl
readonly func InstructionContractHandler_BSTART_TLOAD() => CommandSemanticHandler
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
