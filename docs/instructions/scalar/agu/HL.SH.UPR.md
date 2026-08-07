# HL.SH.UPR

Execute the HL.SH.UPR scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/HL.SH.UPR.asl -->

## Assembly

```asm
hl.sh.upr SrcD, [SrcL, SrcR<{.sw,.uw,.neg}>], ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SH.UPR.asl -->
```asl
readonly func InstructionContractOperation_HL_SH_UPR() => ScalarOperation
begin
    return ScalarOperation_HL_SH_UPR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SH.UPR.asl -->
```asl
readonly func InstructionContractHandler_HL_SH_UPR() => ScalarSemanticHandler
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
