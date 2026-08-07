# HL.MULU

Execute the HL.MULU scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/HL.MULU.asl -->

## Assembly

```asm
hl.mulu SrcL, SrcR, ->Dst0, Dst1
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.MULU.asl -->
```asl
readonly func InstructionContractOperation_HL_MULU() => ScalarOperation
begin
    return ScalarOperation_HL_MULU;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.MULU.asl -->
```asl
readonly func InstructionContractHandler_HL_MULU() => ScalarSemanticHandler
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
