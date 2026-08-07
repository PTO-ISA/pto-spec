# LB.PCR

Execute the LB.PCR scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/LB.PCR.asl -->

## Assembly

```asm
lb.pcr [symbol], ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/LB.PCR.asl -->
```asl
readonly func InstructionContractOperation_LB_PCR() => ScalarOperation
begin
    return ScalarOperation_LB_PCR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/LB.PCR.asl -->
```asl
readonly func InstructionContractHandler_LB_PCR() => ScalarSemanticHandler
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
