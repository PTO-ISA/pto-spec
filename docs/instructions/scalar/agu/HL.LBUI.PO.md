# HL.LBUI.PO

Execute the HL.LBUI.PO scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/HL.LBUI.PO.asl -->

## Assembly

```asm
hl.lbui.po [SrcL, simm], ->Dst0, Dst1
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LBUI.PO.asl -->
```asl
readonly func InstructionContractOperation_HL_LBUI_PO() => ScalarOperation
begin
    return ScalarOperation_HL_LBUI_PO;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LBUI.PO.asl -->
```asl
readonly func InstructionContractHandler_HL_LBUI_PO() => ScalarSemanticHandler
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
