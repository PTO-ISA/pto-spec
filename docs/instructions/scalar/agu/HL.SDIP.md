# HL.SDIP

Execute the HL.SDIP scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/HL.SDIP.asl -->

## Assembly

```asm
hl.sdip SrcD, SrcD1, [SrcR, simm]
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SDIP.asl -->
```asl
readonly func InstructionContractOperation_HL_SDIP() => ScalarOperation
begin
    return ScalarOperation_HL_SDIP;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SDIP.asl -->
```asl
readonly func InstructionContractHandler_HL_SDIP() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStorePair;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
