# HL.LDIP.U

Execute the HL.LDIP.U scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/HL.LDIP.U.asl -->

## Assembly

```asm
hl.ldip.u [SrcL, simm], ->Dst0, Dst1
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LDIP.U.asl -->
```asl
readonly func InstructionContractOperation_HL_LDIP_U() => ScalarOperation
begin
    return ScalarOperation_HL_LDIP_U;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LDIP.U.asl -->
```asl
readonly func InstructionContractHandler_HL_LDIP_U() => ScalarSemanticHandler
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
