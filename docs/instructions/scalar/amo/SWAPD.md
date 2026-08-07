# SWAPD

Execute the SWAPD scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/amo/SWAPD.asl -->

## Assembly

```asm
swapd<.{aq, rl, f, aqrl, aqf, rlf, aqrlf}> [SrcL], SrcR, {->t, ->u, ->Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/SWAPD.asl -->
```asl
readonly func InstructionContractOperation_SWAPD() => ScalarOperation
begin
    return ScalarOperation_SWAPD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/SWAPD.asl -->
```asl
readonly func InstructionContractHandler_SWAPD() => ScalarSemanticHandler
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
