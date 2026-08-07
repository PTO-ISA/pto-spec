# FEQS

Execute the FEQS scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/fsu/FEQS.asl -->

## Assembly

```asm
feqs.{T} SrcL, SrcR, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/FEQS.asl -->
```asl
readonly func InstructionContractOperation_FEQS() => ScalarOperation
begin
    return ScalarOperation_FEQS;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/FEQS.asl -->
```asl
readonly func InstructionContractHandler_FEQS() => ScalarSemanticHandler
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
