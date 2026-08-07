# HL.DIV

Execute the HL.DIV scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/HL.DIV.asl -->

## Assembly

```asm
hl.div SrcL, SrcR, ->Dst0, Dst1
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.DIV.asl -->
```asl
readonly func InstructionContractOperation_HL_DIV() => ScalarOperation
begin
    return ScalarOperation_HL_DIV;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.DIV.asl -->
```asl
readonly func InstructionContractHandler_HL_DIV() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarDividePair;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
