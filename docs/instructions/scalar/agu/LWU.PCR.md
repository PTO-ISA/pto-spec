# LWU.PCR

Execute the LWU.PCR scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/LWU.PCR.asl -->

## Assembly

```asm
lwu.pcr [symbol], ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/LWU.PCR.asl -->
```asl
readonly func InstructionContractOperation_LWU_PCR() => ScalarOperation
begin
    return ScalarOperation_LWU_PCR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/LWU.PCR.asl -->
```asl
readonly func InstructionContractHandler_LWU_PCR() => ScalarSemanticHandler
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
