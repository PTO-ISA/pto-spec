# CMP.NE

Execute the CMP.NE scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/bru/CMP.NE.asl -->

## Assembly

```asm
cmp.ne SrcL, SrcR<{.sw, .uw}>, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/CMP.NE.asl -->
```asl
readonly func InstructionContractOperation_CMP_NE() => ScalarOperation
begin
    return ScalarOperation_CMP_NE;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/CMP.NE.asl -->
```asl
readonly func InstructionContractHandler_CMP_NE() => ScalarSemanticHandler
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
