# HL.LDI.U

Execute the HL.LDI.U scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/HL.LDI.U.asl -->

## Assembly

```asm
hl.ldi.u [SrcL, simm], ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LDI.U.asl -->
```asl
readonly func InstructionContractOperation_HL_LDI_U() => ScalarOperation
begin
    return ScalarOperation_HL_LDI_U;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LDI.U.asl -->
```asl
readonly func InstructionContractHandler_HL_LDI_U() => ScalarSemanticHandler
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
