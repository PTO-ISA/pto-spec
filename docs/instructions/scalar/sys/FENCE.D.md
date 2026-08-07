# FENCE.D

Execute the FENCE.D scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/sys/FENCE.D.asl -->

## Assembly

```asm
fence.d pred_imm, succ_imm
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/FENCE.D.asl -->
```asl
readonly func InstructionContractOperation_FENCE_D() => ScalarOperation
begin
    return ScalarOperation_FENCE_D;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/FENCE.D.asl -->
```asl
readonly func InstructionContractHandler_FENCE_D() => ScalarSemanticHandler
begin
    return ScalarHandler_FenceData;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
