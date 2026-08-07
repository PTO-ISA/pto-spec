# CMP.EQ

Execute the CMP.EQ scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/bru/CMP.EQ.asl -->

## Assembly

```asm
cmp.eq SrcL, SrcR<{.sw, .uw}>, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/CMP.EQ.asl -->
```asl
readonly func InstructionContractOperation_CMP_EQ() => ScalarOperation
begin
    return ScalarOperation_CMP_EQ;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/CMP.EQ.asl -->
```asl
readonly func InstructionContractHandler_CMP_EQ() => ScalarSemanticHandler
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
