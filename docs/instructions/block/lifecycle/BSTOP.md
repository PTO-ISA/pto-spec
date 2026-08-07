# BSTOP

Commits the current bundle and transfers to its selected continuation.

<!-- ASL-SOURCE: asl/block/lifecycle/BSTOP.asl -->

## Assembly

```asm
BSTOP
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/lifecycle/BSTOP.asl -->
```asl
readonly func InstructionContractMatches_BSTOP(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstop_32_d25b09fdd59c);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/lifecycle/BSTOP.asl -->
```asl
readonly func InstructionContractHandler_BSTOP() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStop;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
