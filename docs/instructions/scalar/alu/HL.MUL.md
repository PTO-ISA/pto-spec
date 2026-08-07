# HL.MUL

Execute the HL.MUL scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/HL.MUL.asl -->

## Assembly

```asm
hl.mul SrcL, SrcR, ->Dst0, Dst1
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.MUL.asl -->
```asl
readonly func InstructionContractOperation_HL_MUL() => ScalarOperation
begin
    return ScalarOperation_HL_MUL;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.MUL.asl -->
```asl
readonly func InstructionContractHandler_HL_MUL() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarMultiplyPair;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
