# HL.MIADD

Execute the HL.MIADD scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/HL.MIADD.asl -->

## Assembly

```asm
hl.miadd SrcL, SrcR, uimm, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.MIADD.asl -->
```asl
readonly func InstructionContractOperation_HL_MIADD() => ScalarOperation
begin
    return ScalarOperation_HL_MIADD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.MIADD.asl -->
```asl
readonly func InstructionContractHandler_HL_MIADD() => ScalarSemanticHandler
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
