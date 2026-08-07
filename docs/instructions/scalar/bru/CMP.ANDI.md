# CMP.ANDI

Execute the CMP.ANDI scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/bru/CMP.ANDI.asl -->

## Assembly

```asm
cmp.andi SrcL, simm, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/CMP.ANDI.asl -->
```asl
readonly func InstructionContractOperation_CMP_ANDI() => ScalarOperation
begin
    return ScalarOperation_CMP_ANDI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/CMP.ANDI.asl -->
```asl
readonly func InstructionContractHandler_CMP_ANDI() => ScalarSemanticHandler
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
