# BSTART.TGEMVMX

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

<!-- ASL-SOURCE: asl/block/execution/BSTART.TGEMVMX.asl -->

## Assembly

```asm
BSTART.TGEMVMX DataType
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.TGEMVMX.asl -->
```asl
readonly func InstructionContractMatches_BSTART_TGEMVMX(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_tgemvmx_32_ae5e005f6589);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.TGEMVMX.asl -->
```asl
readonly func InstructionContractHandler_BSTART_TGEMVMX() => CommandSemanticHandler
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
