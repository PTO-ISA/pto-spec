# SRAW

Execute the SRAW scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/SRAW.asl -->

## Assembly

```asm
sraw SrcL, SrcR, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/SRAW.asl -->
```asl
readonly func InstructionContractOperation_SRAW() => ScalarOperation
begin
    return ScalarOperation_SRAW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/SRAW.asl -->
```asl
readonly func InstructionContractHandler_SRAW() => ScalarSemanticHandler
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
