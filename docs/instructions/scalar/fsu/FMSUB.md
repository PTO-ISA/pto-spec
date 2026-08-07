# FMSUB

Execute the FMSUB scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/fsu/FMSUB.asl -->

## Assembly

```asm
fmsub.{T} SrcL, SrcR, SrcA, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/FMSUB.asl -->
```asl
readonly func InstructionContractOperation_FMSUB() => ScalarOperation
begin
    return ScalarOperation_FMSUB;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/FMSUB.asl -->
```asl
readonly func InstructionContractHandler_FMSUB() => ScalarSemanticHandler
begin
    return ScalarHandler_FloatingFused;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
