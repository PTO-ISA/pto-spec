# REV

Execute the REV scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/REV.asl -->

## Assembly

```asm
rev SrcL,  M, N, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/REV.asl -->
```asl
readonly func InstructionContractOperation_REV() => ScalarOperation
begin
    return ScalarOperation_REV;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/REV.asl -->
```asl
readonly func InstructionContractHandler_REV() => ScalarSemanticHandler
begin
    return ScalarHandler_ReverseBitfieldBytes;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
