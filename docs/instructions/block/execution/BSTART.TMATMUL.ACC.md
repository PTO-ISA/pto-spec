# BSTART.TMATMUL.ACC

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

<!-- ASL-SOURCE: asl/block/execution/BSTART.TMATMUL.ACC.asl -->

## Assembly

```asm
BSTART.TMATMUL.ACC DataType
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.TMATMUL.ACC.asl -->
```asl
readonly func InstructionContractMatches_BSTART_TMATMUL_ACC(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_tmatmul_acc_32_0c8c62e5f00a);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.TMATMUL.ACC.asl -->
```asl
readonly func InstructionContractHandler_BSTART_TMATMUL_ACC() => CommandSemanticHandler
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
