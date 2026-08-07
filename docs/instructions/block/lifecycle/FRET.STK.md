# FRET.STK

Restores a frame and returns through the validated stack target.

<!-- ASL-SOURCE: asl/block/lifecycle/FRET.STK.asl -->

## Assembly

```asm
FRET.STK [RegDst0 ~ RegDstn], sp!, uimm
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/lifecycle/FRET.STK.asl -->
```asl
readonly func InstructionContractMatches_FRET_STK(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_fret_stk_32_4fe246bd8241);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/lifecycle/FRET.STK.asl -->
```asl
readonly func InstructionContractHandler_FRET_STK() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteFrameReturnStack;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
