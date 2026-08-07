# HL.SDP

Execute the HL.SDP scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/HL.SDP.asl -->

## Assembly

```asm
hl.sdp SrcD, SrcD1, [SrcL, SrcR<{.sw,.uw,.neg}><<3]
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SDP.asl -->
```asl
readonly func InstructionContractOperation_HL_SDP() => ScalarOperation
begin
    return ScalarOperation_HL_SDP;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SDP.asl -->
```asl
readonly func InstructionContractHandler_HL_SDP() => ScalarSemanticHandler
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
