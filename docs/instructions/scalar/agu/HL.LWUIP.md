# HL.LWUIP

Execute the HL.LWUIP scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/HL.LWUIP.asl -->

## Assembly

```asm
hl.lwuip [SrcL, simm], ->Dst0, Dst1
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LWUIP.asl -->
```asl
readonly func InstructionContractOperation_HL_LWUIP() => ScalarOperation
begin
    return ScalarOperation_HL_LWUIP;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LWUIP.asl -->
```asl
readonly func InstructionContractHandler_HL_LWUIP() => ScalarSemanticHandler
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
