# MCOPY

Copies an encoded memory range with instruction-atomic preflight and snapshot semantics.

<!-- ASL-SOURCE: asl/block/lifecycle/MCOPY.asl -->

## Assembly

```asm
MCOPY [RegSrc0, RegSrc1, RegSrc2]
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/lifecycle/MCOPY.asl -->
```asl
readonly func InstructionContractMatches_MCOPY(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_mcopy_32_4fc4a803e995);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/lifecycle/MCOPY.asl -->
```asl
readonly func InstructionContractHandler_MCOPY() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteMemoryCopy;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
