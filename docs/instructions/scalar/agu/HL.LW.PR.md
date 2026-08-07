# HL.LW.PR

Execute the HL.LW.PR scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/HL.LW.PR.asl -->

## Assembly

```asm
hl.lw.pr [SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>], ->Dst0, Dst1
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LW.PR.asl -->
```asl
readonly func InstructionContractOperation_HL_LW_PR() => ScalarOperation
begin
    return ScalarOperation_HL_LW_PR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LW.PR.asl -->
```asl
readonly func InstructionContractHandler_HL_LW_PR() => ScalarSemanticHandler
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
