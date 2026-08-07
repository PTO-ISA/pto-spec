# FGE

Execute the FGE scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/fsu/FGE.asl -->

## Assembly

```asm
fge.{T} SrcL, SrcR, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/FGE.asl -->
```asl
readonly func InstructionContractOperation_FGE() => ScalarOperation
begin
    return ScalarOperation_FGE;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/FGE.asl -->
```asl
readonly func InstructionContractHandler_FGE() => ScalarSemanticHandler
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
