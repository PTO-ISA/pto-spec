# BIS

Execute the BIS scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/BIS.asl -->

## Assembly

```asm
bis SrcL, M, N, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/BIS.asl -->
```asl
readonly func InstructionContractOperation_BIS() => ScalarOperation
begin
    return ScalarOperation_BIS;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/BIS.asl -->
```asl
readonly func InstructionContractHandler_BIS() => ScalarSemanticHandler
begin
    return ScalarHandler_ModifyBitfield;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
