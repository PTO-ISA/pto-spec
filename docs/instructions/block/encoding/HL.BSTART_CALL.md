# HL.BSTART CALL

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

<!-- ASL-SOURCE: asl/block/encoding/HL.BSTART_CALL.asl -->

## Assembly

```asm
HL.BSTART.CALL <br_label>, <rt_label>, ->ra
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/encoding/HL.BSTART_CALL.asl -->
```asl
readonly func InstructionContractMatches_HL_BSTART_CALL(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_hl_bstart_call_48_3c784c583c90);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/encoding/HL.BSTART_CALL.asl -->
```asl
readonly func InstructionContractHandler_HL_BSTART_CALL() => CommandSemanticHandler
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
