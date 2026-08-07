# BSTART.MSEQ

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

<!-- ASL-SOURCE: asl/block/execution/BSTART.MSEQ.asl -->

## Assembly

```asm
BSTART.MSEQ <VS8, VS16>
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.MSEQ.asl -->
```asl
readonly func InstructionContractMatches_BSTART_MSEQ(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_mseq_32_39343a456ec5);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.MSEQ.asl -->
```asl
readonly func InstructionContractHandler_BSTART_MSEQ() => CommandSemanticHandler
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
