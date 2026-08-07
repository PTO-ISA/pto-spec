# SC.H

Execute the SC.H scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/amo/SC.H.asl -->

## Assembly

```asm
sc.h<.{aq, rl, f, aqrl, aqf, rlf, aqrlf}> SrcL, [SrcR], {->t, ->u, ->Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/SC.H.asl -->
```asl
readonly func InstructionContractOperation_SC_H() => ScalarOperation
begin
    return ScalarOperation_SC_H;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/SC.H.asl -->
```asl
readonly func InstructionContractHandler_SC_H() => ScalarSemanticHandler
begin
    return ScalarHandler_StoreConditional;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
