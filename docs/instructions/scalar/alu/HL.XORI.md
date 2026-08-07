# HL.XORI

Execute the HL.XORI scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/HL.XORI.asl -->

## Assembly

```asm
hl.xori SrcL, simm, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.XORI.asl -->
```asl
readonly func InstructionContractOperation_HL_XORI() => ScalarOperation
begin
    return ScalarOperation_HL_XORI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.XORI.asl -->
```asl
readonly func InstructionContractHandler_HL_XORI() => ScalarSemanticHandler
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
