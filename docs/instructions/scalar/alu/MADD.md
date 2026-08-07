# MADD

Execute the MADD scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/MADD.asl -->

## Assembly

```asm
madd SrcL, SrcR, SrcD, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/MADD.asl -->
```asl
readonly func InstructionContractOperation_MADD() => ScalarOperation
begin
    return ScalarOperation_MADD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/MADD.asl -->
```asl
readonly func InstructionContractHandler_MADD() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarMultiplyAdd;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
