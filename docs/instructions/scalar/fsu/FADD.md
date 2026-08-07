# FADD

Execute the FADD scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/fsu/FADD.asl -->

## Assembly

```asm
fadd.{T} SrcL, SrcR, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/FADD.asl -->
```asl
readonly func InstructionContractOperation_FADD() => ScalarOperation
begin
    return ScalarOperation_FADD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/FADD.asl -->
```asl
readonly func InstructionContractHandler_FADD() => ScalarSemanticHandler
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
