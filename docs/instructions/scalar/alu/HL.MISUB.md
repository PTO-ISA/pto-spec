# HL.MISUB

Execute the HL.MISUB scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/HL.MISUB.asl -->

## Assembly

```asm
hl.misub SrcL, SrcR, uimm, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.MISUB.asl -->
```asl
readonly func InstructionContractOperation_HL_MISUB() => ScalarOperation
begin
    return ScalarOperation_HL_MISUB;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.MISUB.asl -->
```asl
readonly func InstructionContractHandler_HL_MISUB() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarMultiplyImmediateAdd;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
