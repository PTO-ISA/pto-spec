# HL.DIVW

Execute the HL.DIVW scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/HL.DIVW.asl -->

## Assembly

```asm
hl.divw SrcL, SrcR, ->Dst0, Dst1
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.DIVW.asl -->
```asl
readonly func InstructionContractOperation_HL_DIVW() => ScalarOperation
begin
    return ScalarOperation_HL_DIVW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.DIVW.asl -->
```asl
readonly func InstructionContractHandler_HL_DIVW() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarDividePairW;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
