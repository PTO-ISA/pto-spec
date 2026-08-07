# HL.CCAT

Execute the HL.CCAT scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/HL.CCAT.asl -->

## Assembly

```asm
hl.ccat SrcL, SrcR, shamt, ->Dst0, Dst1
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.CCAT.asl -->
```asl
readonly func InstructionContractOperation_HL_CCAT() => ScalarOperation
begin
    return ScalarOperation_HL_CCAT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.CCAT.asl -->
```asl
readonly func InstructionContractHandler_HL_CCAT() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteConcatenatePair;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
