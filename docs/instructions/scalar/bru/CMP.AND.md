# CMP.AND

Execute the CMP.AND scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/bru/CMP.AND.asl -->

## Assembly

```asm
cmp.and SrcL, SrcR<.sw, .uw, .not>, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/CMP.AND.asl -->
```asl
readonly func InstructionContractOperation_CMP_AND() => ScalarOperation
begin
    return ScalarOperation_CMP_AND;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/CMP.AND.asl -->
```asl
readonly func InstructionContractHandler_CMP_AND() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteCompareLogical;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
