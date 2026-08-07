# HL.SD.PR

Execute the HL.SD.PR scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/HL.SD.PR.asl -->

## Assembly

```asm
hl.sd.pr SrcD, [SrcL, SrcR<{.sw,.uw,.neg}><<3], ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SD.PR.asl -->
```asl
readonly func InstructionContractOperation_HL_SD_PR() => ScalarOperation
begin
    return ScalarOperation_HL_SD_PR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SD.PR.asl -->
```asl
readonly func InstructionContractHandler_HL_SD_PR() => ScalarSemanticHandler
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
