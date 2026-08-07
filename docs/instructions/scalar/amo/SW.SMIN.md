# SW.SMIN

Execute the SW.SMIN scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/amo/SW.SMIN.asl -->

## Assembly

```asm
sw.smin<.{rl, f, rlf}> [SrcL], SrcR
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/SW.SMIN.asl -->
```asl
readonly func InstructionContractOperation_SW_SMIN() => ScalarOperation
begin
    return ScalarOperation_SW_SMIN;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/SW.SMIN.asl -->
```asl
readonly func InstructionContractHandler_SW_SMIN() => ScalarSemanticHandler
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
