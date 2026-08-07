# CASD

Execute the CASD scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/amo/CASD.asl -->

## Assembly

```asm
casd<.{aq, rl, aqrl}> [SrcL], SrcR, SrcD, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/CASD.asl -->
```asl
readonly func InstructionContractOperation_CASD() => ScalarOperation
begin
    return ScalarOperation_CASD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/CASD.asl -->
```asl
readonly func InstructionContractHandler_CASD() => ScalarSemanticHandler
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
