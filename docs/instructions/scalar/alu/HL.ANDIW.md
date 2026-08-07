# HL.ANDIW

Execute the HL.ANDIW scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/HL.ANDIW.asl -->

## Assembly

```asm
hl.andiw SrcL, simm, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.ANDIW.asl -->
```asl
readonly func InstructionContractOperation_HL_ANDIW() => ScalarOperation
begin
    return ScalarOperation_HL_ANDIW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.ANDIW.asl -->
```asl
readonly func InstructionContractHandler_HL_ANDIW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
