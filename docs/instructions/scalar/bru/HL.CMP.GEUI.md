# HL.CMP.GEUI

Execute the HL.CMP.GEUI scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/bru/HL.CMP.GEUI.asl -->

## Assembly

```asm
hl.cmp.geui SrcL, uimm, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/HL.CMP.GEUI.asl -->
```asl
readonly func InstructionContractOperation_HL_CMP_GEUI() => ScalarOperation
begin
    return ScalarOperation_HL_CMP_GEUI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/HL.CMP.GEUI.asl -->
```asl
readonly func InstructionContractHandler_HL_CMP_GEUI() => ScalarSemanticHandler
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
