# BSTART.MGATHER

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

<!-- ASL-SOURCE: asl/block/execution/BSTART.MGATHER.asl -->

## Assembly

```asm
BSTART.MGATHER DataType
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.MGATHER.asl -->
```asl
readonly func InstructionContractMatches_BSTART_MGATHER(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_mgather_32_c9defbf18276);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.MGATHER.asl -->
```asl
readonly func InstructionContractHandler_BSTART_MGATHER() => CommandSemanticHandler
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
