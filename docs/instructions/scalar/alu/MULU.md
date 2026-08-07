# MULU

Execute the MULU scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/MULU.asl -->

## Assembly

```asm
mulu SrcL, SrcR, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/MULU.asl -->
```asl
readonly func InstructionContractOperation_MULU() => ScalarOperation
begin
    return ScalarOperation_MULU;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/MULU.asl -->
```asl
readonly func InstructionContractHandler_MULU() => ScalarSemanticHandler
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
