# ADD

Execute the ADD scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/ADD.asl -->

## Assembly

```asm
add SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/ADD.asl -->
```asl
readonly func InstructionContractOperation_ADD() => ScalarOperation
begin
    return ScalarOperation_ADD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/ADD.asl -->
```asl
readonly func InstructionContractHandler_ADD() => ScalarSemanticHandler
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
