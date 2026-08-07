# BSTART.TGEMV.ACC

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

<!-- ASL-SOURCE: asl/block/execution/BSTART.TGEMV.ACC.asl -->

## Assembly

```asm
BSTART.TGEMV.ACC DataType
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.TGEMV.ACC.asl -->
```asl
readonly func InstructionContractMatches_BSTART_TGEMV_ACC(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_tgemv_acc_32_9a471b21913e);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.TGEMV.ACC.asl -->
```asl
readonly func InstructionContractHandler_BSTART_TGEMV_ACC() => CommandSemanticHandler
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
