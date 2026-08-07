# AND

Execute the AND scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/AND.asl -->

## Assembly

```asm
and SrcL, SrcR<{.sw,.uw,.not}><<<shamt>, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/AND.asl -->
```asl
readonly func InstructionContractOperation_AND() => ScalarOperation
begin
    return ScalarOperation_AND;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/AND.asl -->
```asl
readonly func InstructionContractHandler_AND() => ScalarSemanticHandler
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
