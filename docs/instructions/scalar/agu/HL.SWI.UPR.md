# HL.SWI.UPR

Execute the HL.SWI.UPR scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/HL.SWI.UPR.asl -->

## Assembly

```asm
hl.swi.upr SrcD, [SrcR, simm], ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SWI.UPR.asl -->
```asl
readonly func InstructionContractOperation_HL_SWI_UPR() => ScalarOperation
begin
    return ScalarOperation_HL_SWI_UPR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SWI.UPR.asl -->
```asl
readonly func InstructionContractHandler_HL_SWI_UPR() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
