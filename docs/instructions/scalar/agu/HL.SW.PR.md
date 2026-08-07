# HL.SW.PR

Execute the HL.SW.PR scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/HL.SW.PR.asl -->

## Assembly

```asm
hl.sw.pr SrcD, [SrcL, SrcR<{.sw,.uw,.neg}><<2], ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SW.PR.asl -->
```asl
readonly func InstructionContractOperation_HL_SW_PR() => ScalarOperation
begin
    return ScalarOperation_HL_SW_PR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SW.PR.asl -->
```asl
readonly func InstructionContractHandler_HL_SW_PR() => ScalarSemanticHandler
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
