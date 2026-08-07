# REM

Execute the REM scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/REM.asl -->

## Assembly

```asm
rem SrcL, SrcR, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/REM.asl -->
```asl
readonly func InstructionContractOperation_REM() => ScalarOperation
begin
    return ScalarOperation_REM;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/REM.asl -->
```asl
readonly func InstructionContractHandler_REM() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarRemainderSigned;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
