# HL.LHUP

Execute the HL.LHUP scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/HL.LHUP.asl -->

## Assembly

```asm
hl.lhup [SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>], ->Dst0, Dst1
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LHUP.asl -->
```asl
readonly func InstructionContractOperation_HL_LHUP() => ScalarOperation
begin
    return ScalarOperation_HL_LHUP;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LHUP.asl -->
```asl
readonly func InstructionContractHandler_HL_LHUP() => ScalarSemanticHandler
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
