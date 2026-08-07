# C.BSTART.MSEQ

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

<!-- ASL-SOURCE: asl/block/encoding/C.BSTART.MSEQ.asl -->

## Assembly

```asm
C.BSTART.MSEQ FALL
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/encoding/C.BSTART.MSEQ.asl -->
```asl
readonly func InstructionContractMatches_C_BSTART_MSEQ(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_c_bstart_mseq_16_b5597e0e41c2);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/encoding/C.BSTART.MSEQ.asl -->
```asl
readonly func InstructionContractHandler_C_BSTART_MSEQ() => CommandSemanticHandler
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
