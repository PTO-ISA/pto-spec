# BSTART.MPAR

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

<!-- ASL-SOURCE: asl/block/execution/BSTART.MPAR.asl -->

## Assembly

```asm
BSTART.MPAR <VS8, VS16>
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.MPAR.asl -->
```asl
readonly func InstructionContractMatches_BSTART_MPAR(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_mpar_32_2d163417c615);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.MPAR.asl -->
```asl
readonly func InstructionContractHandler_BSTART_MPAR() => CommandSemanticHandler
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
