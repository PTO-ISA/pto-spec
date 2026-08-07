# FGES

Execute the FGES scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/fsu/FGES.asl -->

## Assembly

```asm
fges.{T} SrcL, SrcR, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/FGES.asl -->
```asl
readonly func InstructionContractOperation_FGES() => ScalarOperation
begin
    return ScalarOperation_FGES;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/FGES.asl -->
```asl
readonly func InstructionContractHandler_FGES() => ScalarSemanticHandler
begin
    return ScalarHandler_FloatingCompare;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
