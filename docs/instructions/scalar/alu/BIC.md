# BIC

Execute the BIC scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/BIC.asl -->

## Assembly

```asm
bic SrcL, M, N, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/BIC.asl -->
```asl
readonly func InstructionContractOperation_BIC() => ScalarOperation
begin
    return ScalarOperation_BIC;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/BIC.asl -->
```asl
readonly func InstructionContractHandler_BIC() => ScalarSemanticHandler
begin
    return ScalarHandler_ModifyBitfield;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
