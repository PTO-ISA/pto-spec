# HL.ADDI

Execute the HL.ADDI scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/HL.ADDI.asl -->

## Assembly

```asm
hl.addi SrcL, uimm, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.ADDI.asl -->
```asl
readonly func InstructionContractOperation_HL_ADDI() => ScalarOperation
begin
    return ScalarOperation_HL_ADDI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.ADDI.asl -->
```asl
readonly func InstructionContractHandler_HL_ADDI() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
