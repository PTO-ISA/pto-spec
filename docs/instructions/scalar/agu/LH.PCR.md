# LH.PCR

Execute the LH.PCR scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/LH.PCR.asl -->

## Assembly

```asm
lh.pcr [symbol], ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/LH.PCR.asl -->
```asl
readonly func InstructionContractOperation_LH_PCR() => ScalarOperation
begin
    return ScalarOperation_LH_PCR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/LH.PCR.asl -->
```asl
readonly func InstructionContractHandler_LH_PCR() => ScalarSemanticHandler
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
