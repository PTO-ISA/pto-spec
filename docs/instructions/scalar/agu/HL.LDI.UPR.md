# HL.LDI.UPR

Execute the HL.LDI.UPR scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/HL.LDI.UPR.asl -->

## Assembly

```asm
hl.ldi.upr [SrcL, simm], ->Dst0, Dst1
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LDI.UPR.asl -->
```asl
readonly func InstructionContractOperation_HL_LDI_UPR() => ScalarOperation
begin
    return ScalarOperation_HL_LDI_UPR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LDI.UPR.asl -->
```asl
readonly func InstructionContractHandler_HL_LDI_UPR() => ScalarSemanticHandler
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
