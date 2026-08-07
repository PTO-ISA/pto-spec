# HL.CASH

Execute the HL.CASH scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/amo/HL.CASH.asl -->

## Assembly

```asm
hl.cash<.{aq, rl, f, aqrl, aqf, rlf, aqrlf}> [SrcL], SrcR, SrcD, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/HL.CASH.asl -->
```asl
readonly func InstructionContractOperation_HL_CASH() => ScalarOperation
begin
    return ScalarOperation_HL_CASH;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/HL.CASH.asl -->
```asl
readonly func InstructionContractHandler_HL_CASH() => ScalarSemanticHandler
begin
    return ScalarHandler_CompareAndSwap;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
