# B.EQ

Execute the B.EQ scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/bru/B.EQ.asl -->

## Assembly

```asm
b.eq SrcL, SrcR, label
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/B.EQ.asl -->
```asl
readonly func InstructionContractOperation_B_EQ() => ScalarOperation
begin
    return ScalarOperation_B_EQ;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/B.EQ.asl -->
```asl
readonly func InstructionContractHandler_B_EQ() => ScalarSemanticHandler
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
