# HL.CASD

Execute the HL.CASD scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/amo/HL.CASD.asl -->

## Assembly

```asm
hl.casd<.{aq, rl, f, aqrl, aqf, rlf, aqrlf}> [SrcL], SrcR, SrcD, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/HL.CASD.asl -->
```asl
readonly func InstructionContractOperation_HL_CASD() => ScalarOperation
begin
    return ScalarOperation_HL_CASD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/HL.CASD.asl -->
```asl
readonly func InstructionContractHandler_HL_CASD() => ScalarSemanticHandler
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
