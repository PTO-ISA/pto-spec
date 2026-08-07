# CMP.GE

Execute the CMP.GE scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/bru/CMP.GE.asl -->

## Assembly

```asm
cmp.ge SrcL, SrcR<{.sw, .uw}>, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/CMP.GE.asl -->
```asl
readonly func InstructionContractOperation_CMP_GE() => ScalarOperation
begin
    return ScalarOperation_CMP_GE;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/CMP.GE.asl -->
```asl
readonly func InstructionContractHandler_CMP_GE() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteCompare;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
