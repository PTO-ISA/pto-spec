# FEXIT

Atomically validates and commits a frame-template exit state.

<!-- ASL-SOURCE: asl/block/lifecycle/FEXIT.asl -->

## Assembly

```asm
FEXIT [RegDst0 ~ RegDstn], sp!, uimm
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/lifecycle/FEXIT.asl -->
```asl
readonly func InstructionContractMatches_FEXIT(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_fexit_32_37b663f2a34d);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/lifecycle/FEXIT.asl -->
```asl
readonly func InstructionContractHandler_FEXIT() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteFrameExit;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
