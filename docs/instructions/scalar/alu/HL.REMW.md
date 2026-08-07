# HL.REMW

Execute the HL.REMW scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/HL.REMW.asl -->

## Assembly

```asm
hl.remw SrcL, SrcR, ->Dst0, Dst1
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.REMW.asl -->
```asl
readonly func InstructionContractOperation_HL_REMW() => ScalarOperation
begin
    return ScalarOperation_HL_REMW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.REMW.asl -->
```asl
readonly func InstructionContractHandler_HL_REMW() => ScalarSemanticHandler
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
