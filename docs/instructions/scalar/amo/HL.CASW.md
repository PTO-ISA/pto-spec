# HL.CASW

Execute the HL.CASW scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/amo/HL.CASW.asl -->

## Assembly

```asm
hl.casw<.{aq, rl, f, aqrl, aqf, rlf, aqrlf}> [SrcL], SrcR, SrcD, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/HL.CASW.asl -->
```asl
readonly func InstructionContractOperation_HL_CASW() => ScalarOperation
begin
    return ScalarOperation_HL_CASW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/HL.CASW.asl -->
```asl
readonly func InstructionContractHandler_HL_CASW() => ScalarSemanticHandler
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
