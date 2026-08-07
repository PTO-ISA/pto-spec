# HL.CASB

Execute the HL.CASB scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/amo/HL.CASB.asl -->

## Assembly

```asm
hl.casb<.{aq, rl, f, aqrl, aqf, rlf, aqrlf}> [SrcL], SrcR, SrcD, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/HL.CASB.asl -->
```asl
readonly func InstructionContractOperation_HL_CASB() => ScalarOperation
begin
    return ScalarOperation_HL_CASB;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/HL.CASB.asl -->
```asl
readonly func InstructionContractHandler_HL_CASB() => ScalarSemanticHandler
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
