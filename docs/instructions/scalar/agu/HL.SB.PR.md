# HL.SB.PR

Execute the HL.SB.PR scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/HL.SB.PR.asl -->

## Assembly

```asm
hl.sb.pr SrcD, [SrcL, SrcR<{.sw,.uw,.neg}>], ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SB.PR.asl -->
```asl
readonly func InstructionContractOperation_HL_SB_PR() => ScalarOperation
begin
    return ScalarOperation_HL_SB_PR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SB.PR.asl -->
```asl
readonly func InstructionContractHandler_HL_SB_PR() => ScalarSemanticHandler
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
