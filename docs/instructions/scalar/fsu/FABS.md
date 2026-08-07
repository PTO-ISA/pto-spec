# FABS

Execute the FABS scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/fsu/FABS.asl -->

## Assembly

```asm
fabs.{T} SrcL, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/FABS.asl -->
```asl
readonly func InstructionContractOperation_FABS() => ScalarOperation
begin
    return ScalarOperation_FABS;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/FABS.asl -->
```asl
readonly func InstructionContractHandler_FABS() => ScalarSemanticHandler
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
