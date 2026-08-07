# SB.PCR

Execute the SB.PCR scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/SB.PCR.asl -->

## Assembly

```asm
sb.pcr SrcL, [symbol]
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/SB.PCR.asl -->
```asl
readonly func InstructionContractOperation_SB_PCR() => ScalarOperation
begin
    return ScalarOperation_SB_PCR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/SB.PCR.asl -->
```asl
readonly func InstructionContractHandler_SB_PCR() => ScalarSemanticHandler
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
