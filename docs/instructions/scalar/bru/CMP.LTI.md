# CMP.LTI

Execute the CMP.LTI scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/bru/CMP.LTI.asl -->

## Assembly

```asm
cmp.lti SrcL, simm, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/CMP.LTI.asl -->
```asl
readonly func InstructionContractOperation_CMP_LTI() => ScalarOperation
begin
    return ScalarOperation_CMP_LTI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/CMP.LTI.asl -->
```asl
readonly func InstructionContractHandler_CMP_LTI() => ScalarSemanticHandler
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
