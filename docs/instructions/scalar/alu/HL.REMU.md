# HL.REMU

Execute the HL.REMU scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/HL.REMU.asl -->

## Assembly

```asm
hl.remu SrcL, SrcR, ->Dst0, Dst1
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.REMU.asl -->
```asl
readonly func InstructionContractOperation_HL_REMU() => ScalarOperation
begin
    return ScalarOperation_HL_REMU;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.REMU.asl -->
```asl
readonly func InstructionContractHandler_HL_REMU() => ScalarSemanticHandler
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
