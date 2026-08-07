# HL.LWIP

Execute the HL.LWIP scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/HL.LWIP.asl -->

## Assembly

```asm
hl.lwip [SrcL, simm], ->Dst0, Dst1
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LWIP.asl -->
```asl
readonly func InstructionContractOperation_HL_LWIP() => ScalarOperation
begin
    return ScalarOperation_HL_LWIP;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LWIP.asl -->
```asl
readonly func InstructionContractHandler_HL_LWIP() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoadPair;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
