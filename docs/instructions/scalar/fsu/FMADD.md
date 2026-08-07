# FMADD

Execute the FMADD scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/fsu/FMADD.asl -->

## Assembly

```asm
fmadd.{T} SrcL, SrcR, SrcA, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/FMADD.asl -->
```asl
readonly func InstructionContractOperation_FMADD() => ScalarOperation
begin
    return ScalarOperation_FMADD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/FMADD.asl -->
```asl
readonly func InstructionContractHandler_FMADD() => ScalarSemanticHandler
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
