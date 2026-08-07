# FENCE.I

Execute the FENCE.I scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/sys/FENCE.I.asl -->

## Assembly

```asm
fence.i
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/FENCE.I.asl -->
```asl
readonly func InstructionContractOperation_FENCE_I() => ScalarOperation
begin
    return ScalarOperation_FENCE_I;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/FENCE.I.asl -->
```asl
readonly func InstructionContractHandler_FENCE_I() => ScalarSemanticHandler
begin
    return ScalarHandler_FenceInstruction;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
