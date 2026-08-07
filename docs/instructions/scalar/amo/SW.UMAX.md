# SW.UMAX

Execute the SW.UMAX scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/amo/SW.UMAX.asl -->

## Assembly

```asm
sw.umax<.{rl, f, rlf}> [SrcL], SrcR
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/SW.UMAX.asl -->
```asl
readonly func InstructionContractOperation_SW_UMAX() => ScalarOperation
begin
    return ScalarOperation_SW_UMAX;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/SW.UMAX.asl -->
```asl
readonly func InstructionContractHandler_SW_UMAX() => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
