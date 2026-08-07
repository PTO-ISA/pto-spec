# LR.D

Execute the LR.D scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/amo/LR.D.asl -->

## Assembly

```asm
lr.d<.{aq, rl, f, aqrl, aqf, rlf, aqrlf}> [SrcL], {->t, ->u, ->Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/LR.D.asl -->
```asl
readonly func InstructionContractOperation_LR_D() => ScalarOperation
begin
    return ScalarOperation_LR_D;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/LR.D.asl -->
```asl
readonly func InstructionContractHandler_LR_D() => ScalarSemanticHandler
begin
    return ScalarHandler_LoadReserved;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
