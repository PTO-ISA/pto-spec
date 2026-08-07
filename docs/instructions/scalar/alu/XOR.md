# XOR

Execute the XOR scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/XOR.asl -->

## Assembly

```asm
xor SrcL, SrcR<{.sw,.uw,.not}><<<shamt>, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/XOR.asl -->
```asl
readonly func InstructionContractOperation_XOR() => ScalarOperation
begin
    return ScalarOperation_XOR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/XOR.asl -->
```asl
readonly func InstructionContractHandler_XOR() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
