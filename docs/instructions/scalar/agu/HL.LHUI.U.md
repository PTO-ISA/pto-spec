# HL.LHUI.U

Execute the HL.LHUI.U scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/HL.LHUI.U.asl -->

## Assembly

```asm
hl.lhui.u [SrcL, simm], ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LHUI.U.asl -->
```asl
readonly func InstructionContractOperation_HL_LHUI_U() => ScalarOperation
begin
    return ScalarOperation_HL_LHUI_U;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LHUI.U.asl -->
```asl
readonly func InstructionContractHandler_HL_LHUI_U() => ScalarSemanticHandler
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
