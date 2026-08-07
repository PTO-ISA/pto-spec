# BXU

Execute the BXU scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/BXU.asl -->

## Assembly

```asm
bxu SrcL, M, N, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/BXU.asl -->
```asl
readonly func InstructionContractOperation_BXU() => ScalarOperation
begin
    return ScalarOperation_BXU;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/BXU.asl -->
```asl
readonly func InstructionContractHandler_BXU() => ScalarSemanticHandler
begin
    return ScalarHandler_ExtractBitfield;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
