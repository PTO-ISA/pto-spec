# HL.LWI.UPR

Execute the HL.LWI.UPR scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/HL.LWI.UPR.asl -->

## Assembly

```asm
hl.lwi.upr [SrcL, simm], ->Dst0, Dst1
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LWI.UPR.asl -->
```asl
readonly func InstructionContractOperation_HL_LWI_UPR() => ScalarOperation
begin
    return ScalarOperation_HL_LWI_UPR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LWI.UPR.asl -->
```asl
readonly func InstructionContractHandler_HL_LWI_UPR() => ScalarSemanticHandler
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
