# FNMADD

Execute the FNMADD scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/fsu/FNMADD.asl -->

## Assembly

```asm
fnmadd.{T} SrcL, SrcR, SrcA, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/FNMADD.asl -->
```asl
readonly func InstructionContractOperation_FNMADD() => ScalarOperation
begin
    return ScalarOperation_FNMADD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/FNMADD.asl -->
```asl
readonly func InstructionContractHandler_FNMADD() => ScalarSemanticHandler
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
