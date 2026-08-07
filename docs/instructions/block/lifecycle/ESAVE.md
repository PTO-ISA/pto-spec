# ESAVE

Saves the encoded execution-context range to memory.

<!-- ASL-SOURCE: asl/block/lifecycle/ESAVE.asl -->

## Assembly

```asm
ESAVE [RegSrc0=BasePtr, RegSrc1=LenBytes, RegSrc2=Kind]
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/lifecycle/ESAVE.asl -->
```asl
readonly func InstructionContractMatches_ESAVE(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_esave_32_4c4f79fe3171);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/lifecycle/ESAVE.asl -->
```asl
readonly func InstructionContractHandler_ESAVE() => CommandSemanticHandler
begin
    return CommandHandler_SaveExecutionContext;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
