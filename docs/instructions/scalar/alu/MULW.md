# MULW

Execute the MULW scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/MULW.asl -->

## Assembly

```asm
mulw SrcL, SrcR, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/MULW.asl -->
```asl
readonly func InstructionContractOperation_MULW() => ScalarOperation
begin
    return ScalarOperation_MULW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/MULW.asl -->
```asl
readonly func InstructionContractHandler_MULW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarMultiplyW;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
