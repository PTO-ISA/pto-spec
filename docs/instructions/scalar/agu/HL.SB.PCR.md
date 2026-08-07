# HL.SB.PCR

Execute the HL.SB.PCR scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/HL.SB.PCR.asl -->

## Assembly

```asm
hl.sb.pcr SrcL, [<symbol>]
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SB.PCR.asl -->
```asl
readonly func InstructionContractOperation_HL_SB_PCR() => ScalarOperation
begin
    return ScalarOperation_HL_SB_PCR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SB.PCR.asl -->
```asl
readonly func InstructionContractHandler_HL_SB_PCR() => ScalarSemanticHandler
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
