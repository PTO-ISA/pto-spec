# HL.LB.PCR

Execute the HL.LB.PCR scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/HL.LB.PCR.asl -->

## Assembly

```asm
hl.lb.pcr [<symbol>], ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LB.PCR.asl -->
```asl
readonly func InstructionContractOperation_HL_LB_PCR() => ScalarOperation
begin
    return ScalarOperation_HL_LB_PCR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LB.PCR.asl -->
```asl
readonly func InstructionContractHandler_HL_LB_PCR() => ScalarSemanticHandler
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
