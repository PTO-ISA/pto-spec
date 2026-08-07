# DIV

Execute the DIV scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/DIV.asl -->

## Assembly

```asm
div SrcL, SrcR, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/DIV.asl -->
```asl
readonly func InstructionContractOperation_DIV() => ScalarOperation
begin
    return ScalarOperation_DIV;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/DIV.asl -->
```asl
readonly func InstructionContractHandler_DIV() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarDivideSigned;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
