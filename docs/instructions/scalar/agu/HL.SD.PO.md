# HL.SD.PO

Execute the HL.SD.PO scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/HL.SD.PO.asl -->

## Assembly

```asm
hl.sd.po SrcD, [SrcL, SrcR<{.sw,.uw,.neg}><<3], ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SD.PO.asl -->
```asl
readonly func InstructionContractOperation_HL_SD_PO() => ScalarOperation
begin
    return ScalarOperation_HL_SD_PO;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SD.PO.asl -->
```asl
readonly func InstructionContractHandler_HL_SD_PO() => ScalarSemanticHandler
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
