# HL.SBIP

Execute the HL.SBIP scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/HL.SBIP.asl -->

## Assembly

```asm
hl.sbip SrcD, SrcD1, [SrcR, simm]
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SBIP.asl -->
```asl
readonly func InstructionContractOperation_HL_SBIP() => ScalarOperation
begin
    return ScalarOperation_HL_SBIP;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SBIP.asl -->
```asl
readonly func InstructionContractHandler_HL_SBIP() => ScalarSemanticHandler
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
