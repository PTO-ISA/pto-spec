# HL.LIS

Execute the HL.LIS scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/HL.LIS.asl -->

## Assembly

```asm
hl.lis simm, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.LIS.asl -->
```asl
readonly func InstructionContractOperation_HL_LIS() => ScalarOperation
begin
    return ScalarOperation_HL_LIS;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.LIS.asl -->
```asl
readonly func InstructionContractHandler_HL_LIS() => ScalarSemanticHandler
begin
    return ScalarHandler_MaterializeLongSigned;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
