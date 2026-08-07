# FMAX

Execute the FMAX scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/fsu/FMAX.asl -->

## Assembly

```asm
fmax.{T} SrcL, SrcR, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/FMAX.asl -->
```asl
readonly func InstructionContractOperation_FMAX() => ScalarOperation
begin
    return ScalarOperation_FMAX;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/FMAX.asl -->
```asl
readonly func InstructionContractHandler_FMAX() => ScalarSemanticHandler
begin
    return ScalarHandler_FloatingBinary;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
