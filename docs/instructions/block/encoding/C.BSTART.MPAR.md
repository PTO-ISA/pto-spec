# C.BSTART.MPAR

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

<!-- ASL-SOURCE: asl/block/encoding/C.BSTART.MPAR.asl -->

## Assembly

```asm
C.BSTART.MPAR FALL
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/encoding/C.BSTART.MPAR.asl -->
```asl
readonly func InstructionContractMatches_C_BSTART_MPAR(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_c_bstart_mpar_16_66c3ef2226ec);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/encoding/C.BSTART.MPAR.asl -->
```asl
readonly func InstructionContractHandler_C_BSTART_MPAR() => CommandSemanticHandler
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
