# ERCOV

Recovers the encoded execution-context range from memory.

<!-- ASL-SOURCE: asl/block/lifecycle/ERCOV.asl -->

## Assembly

```asm
ERCOV [RegSrc0=BasePtr, RegSrc1=LenBytes, RegSrc2=Kind]
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/lifecycle/ERCOV.asl -->
```asl
readonly func InstructionContractMatches_ERCOV(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_ercov_32_dc0be14a2d8b);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/lifecycle/ERCOV.asl -->
```asl
readonly func InstructionContractHandler_ERCOV() => CommandSemanticHandler
begin
    return CommandHandler_RecoverExecutionContext;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
