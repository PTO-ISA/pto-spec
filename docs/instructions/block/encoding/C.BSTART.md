# C.BSTART

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

<!-- ASL-SOURCE: asl/block/encoding/C.BSTART.asl -->

## Assembly

```asm
C.BSTART COND,  label
C.BSTART DIRECT, label
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/encoding/C.BSTART.asl -->
```asl
readonly func InstructionContractMatches_C_BSTART(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_c_bstart_16_c4e238a9227a) ||
           (operation == CommandOperation_c_bstart_16_f833d2a4753c);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/encoding/C.BSTART.asl -->
```asl
readonly func InstructionContractHandler_C_BSTART() => CommandSemanticHandler
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
