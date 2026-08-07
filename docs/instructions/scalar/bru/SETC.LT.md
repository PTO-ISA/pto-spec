# SETC.LT

Execute the SETC.LT scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/bru/SETC.LT.asl -->

## Assembly

```asm
setc.lt SrcL, SrcR<{.sw, .uw}>
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/SETC.LT.asl -->
```asl
readonly func InstructionContractOperation_SETC_LT() => ScalarOperation
begin
    return ScalarOperation_SETC_LT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/SETC.LT.asl -->
```asl
readonly func InstructionContractHandler_SETC_LT() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommit;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
