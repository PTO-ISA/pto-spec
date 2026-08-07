# LR.B

Execute the LR.B scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/amo/LR.B.asl -->

## Assembly

```asm
lr.b<.{aq, rl, f, aqrl, aqf, rlf, aqrlf}> [SrcL], {->t, ->u, ->Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/LR.B.asl -->
```asl
readonly func InstructionContractOperation_LR_B() => ScalarOperation
begin
    return ScalarOperation_LR_B;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/LR.B.asl -->
```asl
readonly func InstructionContractHandler_LR_B() => ScalarSemanticHandler
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
