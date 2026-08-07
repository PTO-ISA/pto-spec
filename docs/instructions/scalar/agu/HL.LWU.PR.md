# HL.LWU.PR

Execute the HL.LWU.PR scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/HL.LWU.PR.asl -->

## Assembly

```asm
hl.lwu.pr [SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>], ->Dst0, Dst1
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LWU.PR.asl -->
```asl
readonly func InstructionContractOperation_HL_LWU_PR() => ScalarOperation
begin
    return ScalarOperation_HL_LWU_PR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LWU.PR.asl -->
```asl
readonly func InstructionContractHandler_HL_LWU_PR() => ScalarSemanticHandler
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
