# FDIV

Execute the FDIV scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/fsu/FDIV.asl -->

## Assembly

```asm
fdiv.{T} SrcL, SrcR, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/FDIV.asl -->
```asl
readonly func InstructionContractOperation_FDIV() => ScalarOperation
begin
    return ScalarOperation_FDIV;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/FDIV.asl -->
```asl
readonly func InstructionContractHandler_FDIV() => ScalarSemanticHandler
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
