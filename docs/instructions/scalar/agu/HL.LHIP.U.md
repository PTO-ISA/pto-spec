# HL.LHIP.U

Execute the HL.LHIP.U scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/HL.LHIP.U.asl -->

## Assembly

```asm
hl.lhip.u [SrcL, simm], ->Dst0, Dst1
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LHIP.U.asl -->
```asl
readonly func InstructionContractOperation_HL_LHIP_U() => ScalarOperation
begin
    return ScalarOperation_HL_LHIP_U;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LHIP.U.asl -->
```asl
readonly func InstructionContractHandler_HL_LHIP_U() => ScalarSemanticHandler
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
