# CLZ

Execute the CLZ scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/CLZ.asl -->

## Assembly

```asm
clz SrcL,  M, N, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/CLZ.asl -->
```asl
readonly func InstructionContractOperation_CLZ() => ScalarOperation
begin
    return ScalarOperation_CLZ;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/CLZ.asl -->
```asl
readonly func InstructionContractHandler_CLZ() => ScalarSemanticHandler
begin
    return ScalarHandler_CountBitfield;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
