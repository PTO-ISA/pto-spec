# LW.UMIN

Execute the LW.UMIN scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/amo/LW.UMIN.asl -->

## Assembly

```asm
lw.umin<.{aq, rl, f, aqrl, aqf, rlf, aqrlf}> [SrcL], SrcR, {->t, ->u, ->Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/LW.UMIN.asl -->
```asl
readonly func InstructionContractOperation_LW_UMIN() => ScalarOperation
begin
    return ScalarOperation_LW_UMIN;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/LW.UMIN.asl -->
```asl
readonly func InstructionContractHandler_LW_UMIN() => ScalarSemanticHandler
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
