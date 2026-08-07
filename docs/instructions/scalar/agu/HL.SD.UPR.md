# HL.SD.UPR

Execute the HL.SD.UPR scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/HL.SD.UPR.asl -->

## Assembly

```asm
hl.sd.upr SrcD, [SrcL, SrcR<{.sw,.uw,.neg}>], ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SD.UPR.asl -->
```asl
readonly func InstructionContractOperation_HL_SD_UPR() => ScalarOperation
begin
    return ScalarOperation_HL_SD_UPR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SD.UPR.asl -->
```asl
readonly func InstructionContractHandler_HL_SD_UPR() => ScalarSemanticHandler
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
