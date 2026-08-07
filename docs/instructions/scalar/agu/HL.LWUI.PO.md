# HL.LWUI.PO

Execute the HL.LWUI.PO scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/HL.LWUI.PO.asl -->

## Assembly

```asm
hl.lwui.po [SrcL, simm], ->Dst0, Dst1
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LWUI.PO.asl -->
```asl
readonly func InstructionContractOperation_HL_LWUI_PO() => ScalarOperation
begin
    return ScalarOperation_HL_LWUI_PO;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LWUI.PO.asl -->
```asl
readonly func InstructionContractHandler_HL_LWUI_PO() => ScalarSemanticHandler
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
