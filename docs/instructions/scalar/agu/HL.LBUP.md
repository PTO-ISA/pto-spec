# HL.LBUP

Execute the HL.LBUP scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/HL.LBUP.asl -->

## Assembly

```asm
hl.lbup [SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>], ->Dst0, Dst1
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LBUP.asl -->
```asl
readonly func InstructionContractOperation_HL_LBUP() => ScalarOperation
begin
    return ScalarOperation_HL_LBUP;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LBUP.asl -->
```asl
readonly func InstructionContractHandler_HL_LBUP() => ScalarSemanticHandler
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
