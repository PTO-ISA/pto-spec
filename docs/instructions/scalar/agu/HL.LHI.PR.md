# HL.LHI.PR

Execute the HL.LHI.PR scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/HL.LHI.PR.asl -->

## Assembly

```asm
hl.lhi.pr [SrcL, simm], ->Dst0, Dst1
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LHI.PR.asl -->
```asl
readonly func InstructionContractOperation_HL_LHI_PR() => ScalarOperation
begin
    return ScalarOperation_HL_LHI_PR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LHI.PR.asl -->
```asl
readonly func InstructionContractHandler_HL_LHI_PR() => ScalarSemanticHandler
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
