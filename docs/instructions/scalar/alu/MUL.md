# MUL

Execute the MUL scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/MUL.asl -->

## Assembly

```asm
mul SrcL, SrcR, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/MUL.asl -->
```asl
readonly func InstructionContractOperation_MUL() => ScalarOperation
begin
    return ScalarOperation_MUL;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/MUL.asl -->
```asl
readonly func InstructionContractHandler_MUL() => ScalarSemanticHandler
begin
    return ScalarHandler_MultiplyWord;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
