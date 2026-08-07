# LW.AND

Execute the LW.AND scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/amo/LW.AND.asl -->

## Assembly

```asm
lw.and<.{aq, rl, f, aqrl, aqf, rlf, aqrlf}> [SrcL], SrcR, {->t, ->u, ->Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/LW.AND.asl -->
```asl
readonly func InstructionContractOperation_LW_AND() => ScalarOperation
begin
    return ScalarOperation_LW_AND;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/LW.AND.asl -->
```asl
readonly func InstructionContractHandler_LW_AND() => ScalarSemanticHandler
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
