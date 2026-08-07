# HL.CCATW

Execute the HL.CCATW scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/HL.CCATW.asl -->

## Assembly

```asm
hl.ccatw SrcL, SrcR, shamt, ->Dst0, Dst1
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.CCATW.asl -->
```asl
readonly func InstructionContractOperation_HL_CCATW() => ScalarOperation
begin
    return ScalarOperation_HL_CCATW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.CCATW.asl -->
```asl
readonly func InstructionContractHandler_HL_CCATW() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteConcatenatePairW;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
