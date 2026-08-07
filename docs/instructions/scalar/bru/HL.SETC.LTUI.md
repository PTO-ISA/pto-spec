# HL.SETC.LTUI

Execute the HL.SETC.LTUI scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/bru/HL.SETC.LTUI.asl -->

## Assembly

```asm
hl.setc.ltui SrcL, uimm
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/HL.SETC.LTUI.asl -->
```asl
readonly func InstructionContractOperation_HL_SETC_LTUI() => ScalarOperation
begin
    return ScalarOperation_HL_SETC_LTUI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/HL.SETC.LTUI.asl -->
```asl
readonly func InstructionContractHandler_HL_SETC_LTUI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommit;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
