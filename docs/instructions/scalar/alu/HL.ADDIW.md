# HL.ADDIW

Execute the HL.ADDIW scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/HL.ADDIW.asl -->

## Assembly

```asm
hl.addiw SrcL, uimm, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.ADDIW.asl -->
```asl
readonly func InstructionContractOperation_HL_ADDIW() => ScalarOperation
begin
    return ScalarOperation_HL_ADDIW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.ADDIW.asl -->
```asl
readonly func InstructionContractHandler_HL_ADDIW() => ScalarSemanticHandler
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
