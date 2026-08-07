# HL.LHUIP.U

Execute the HL.LHUIP.U scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/HL.LHUIP.U.asl -->

## Assembly

```asm
hl.lhuip.u [SrcL, simm], ->Dst0, Dst1
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LHUIP.U.asl -->
```asl
readonly func InstructionContractOperation_HL_LHUIP_U() => ScalarOperation
begin
    return ScalarOperation_HL_LHUIP_U;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LHUIP.U.asl -->
```asl
readonly func InstructionContractHandler_HL_LHUIP_U() => ScalarSemanticHandler
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
