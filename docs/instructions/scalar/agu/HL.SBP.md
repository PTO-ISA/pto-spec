# HL.SBP

Execute the HL.SBP scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/HL.SBP.asl -->

## Assembly

```asm
hl.sbp SrcD, SrcD1, [SrcL, SrcR<{.sw,.uw,.neg}>]
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SBP.asl -->
```asl
readonly func InstructionContractOperation_HL_SBP() => ScalarOperation
begin
    return ScalarOperation_HL_SBP;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SBP.asl -->
```asl
readonly func InstructionContractHandler_HL_SBP() => ScalarSemanticHandler
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
