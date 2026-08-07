# FRECIP

Execute the FRECIP scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/fsu/FRECIP.asl -->

## Assembly

```asm
frecip.{T} SrcL, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/FRECIP.asl -->
```asl
readonly func InstructionContractOperation_FRECIP() => ScalarOperation
begin
    return ScalarOperation_FRECIP;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/FRECIP.asl -->
```asl
readonly func InstructionContractHandler_FRECIP() => ScalarSemanticHandler
begin
    return ScalarHandler_FloatingUnary;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
