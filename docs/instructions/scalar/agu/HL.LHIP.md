# HL.LHIP

Execute the HL.LHIP scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/HL.LHIP.asl -->

## Assembly

```asm
hl.lhip [SrcL, simm], ->Dst0, Dst1
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LHIP.asl -->
```asl
readonly func InstructionContractOperation_HL_LHIP() => ScalarOperation
begin
    return ScalarOperation_HL_LHIP;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LHIP.asl -->
```asl
readonly func InstructionContractHandler_HL_LHIP() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoadPair;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
