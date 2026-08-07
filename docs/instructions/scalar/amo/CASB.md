# CASB

Execute the CASB scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/amo/CASB.asl -->

## Assembly

```asm
casb<.{aq, rl, aqrl}> [SrcL], SrcR, SrcD, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/CASB.asl -->
```asl
readonly func InstructionContractOperation_CASB() => ScalarOperation
begin
    return ScalarOperation_CASB;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/CASB.asl -->
```asl
readonly func InstructionContractHandler_CASB() => ScalarSemanticHandler
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
