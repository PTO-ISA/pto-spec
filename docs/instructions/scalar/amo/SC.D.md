# SC.D

Execute the SC.D scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/amo/SC.D.asl -->

## Assembly

```asm
sc.d<.{aq, rl, f, aqrl, aqf, rlf, aqrlf}> SrcL, [SrcR], {->t, ->u, ->Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/SC.D.asl -->
```asl
readonly func InstructionContractOperation_SC_D() => ScalarOperation
begin
    return ScalarOperation_SC_D;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/SC.D.asl -->
```asl
readonly func InstructionContractHandler_SC_D() => ScalarSemanticHandler
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
