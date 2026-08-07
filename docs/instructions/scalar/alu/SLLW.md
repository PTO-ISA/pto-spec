# SLLW

Execute the SLLW scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/SLLW.asl -->

## Assembly

```asm
sllw SrcL, SrcR, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/SLLW.asl -->
```asl
readonly func InstructionContractOperation_SLLW() => ScalarOperation
begin
    return ScalarOperation_SLLW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/SLLW.asl -->
```asl
readonly func InstructionContractHandler_SLLW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
