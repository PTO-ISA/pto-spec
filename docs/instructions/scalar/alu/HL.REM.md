# HL.REM

Execute the HL.REM scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/HL.REM.asl -->

## Assembly

```asm
hl.rem SrcL, SrcR, ->Dst0, Dst1
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.REM.asl -->
```asl
readonly func InstructionContractOperation_HL_REM() => ScalarOperation
begin
    return ScalarOperation_HL_REM;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.REM.asl -->
```asl
readonly func InstructionContractHandler_HL_REM() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarDividePair;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
