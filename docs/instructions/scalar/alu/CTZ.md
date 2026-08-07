# CTZ

Execute the CTZ scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/CTZ.asl -->

## Assembly

```asm
ctz SrcL,  M, N, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/CTZ.asl -->
```asl
readonly func InstructionContractOperation_CTZ() => ScalarOperation
begin
    return ScalarOperation_CTZ;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/CTZ.asl -->
```asl
readonly func InstructionContractHandler_CTZ() => ScalarSemanticHandler
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
