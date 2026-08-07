# HL.LHUI.PR

Execute the HL.LHUI.PR scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/HL.LHUI.PR.asl -->

## Assembly

```asm
hl.lhui.pr [SrcL, simm], ->Dst0, Dst1
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LHUI.PR.asl -->
```asl
readonly func InstructionContractOperation_HL_LHUI_PR() => ScalarOperation
begin
    return ScalarOperation_HL_LHUI_PR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LHUI.PR.asl -->
```asl
readonly func InstructionContractHandler_HL_LHUI_PR() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
