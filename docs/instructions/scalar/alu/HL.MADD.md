# HL.MADD

Execute the HL.MADD scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/HL.MADD.asl -->

## Assembly

```asm
hl.madd SrcL, SrcR, SrcD, ->Dst0, Dst1
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.MADD.asl -->
```asl
readonly func InstructionContractOperation_HL_MADD() => ScalarOperation
begin
    return ScalarOperation_HL_MADD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.MADD.asl -->
```asl
readonly func InstructionContractHandler_HL_MADD() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarMultiplyAddPair;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
