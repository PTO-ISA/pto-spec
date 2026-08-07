# CMP.ORI

Execute the CMP.ORI scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/bru/CMP.ORI.asl -->

## Assembly

```asm
cmp.ori SrcL, simm, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/CMP.ORI.asl -->
```asl
readonly func InstructionContractOperation_CMP_ORI() => ScalarOperation
begin
    return ScalarOperation_CMP_ORI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/CMP.ORI.asl -->
```asl
readonly func InstructionContractHandler_CMP_ORI() => ScalarSemanticHandler
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
