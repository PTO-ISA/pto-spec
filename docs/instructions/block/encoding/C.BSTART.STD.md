# C.BSTART.STD

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

<!-- ASL-SOURCE: asl/block/encoding/C.BSTART.STD.asl -->

## Assembly

```asm
C.BSTART.STD BrType
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/encoding/C.BSTART.STD.asl -->
```asl
readonly func InstructionContractMatches_C_BSTART_STD(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_c_bstart_std_16_8b40f078c14a);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/encoding/C.BSTART.STD.asl -->
```asl
readonly func InstructionContractHandler_C_BSTART_STD() => CommandSemanticHandler
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
