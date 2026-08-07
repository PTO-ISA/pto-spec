# B.GEU

Execute the B.GEU scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/bru/B.GEU.asl -->

## Assembly

```asm
b.geu SrcL, SrcR, label
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/B.GEU.asl -->
```asl
readonly func InstructionContractOperation_B_GEU() => ScalarOperation
begin
    return ScalarOperation_B_GEU;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/B.GEU.asl -->
```asl
readonly func InstructionContractHandler_B_GEU() => ScalarSemanticHandler
begin
    return ScalarHandler_BranchRelative;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
