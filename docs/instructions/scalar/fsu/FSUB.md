# FSUB

Execute the FSUB scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/fsu/FSUB.asl -->

## Assembly

```asm
fsub.{T} SrcL, SrcR, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/FSUB.asl -->
```asl
readonly func InstructionContractOperation_FSUB() => ScalarOperation
begin
    return ScalarOperation_FSUB;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/FSUB.asl -->
```asl
readonly func InstructionContractHandler_FSUB() => ScalarSemanticHandler
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
