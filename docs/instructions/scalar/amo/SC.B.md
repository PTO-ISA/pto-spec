# SC.B

Execute the SC.B scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/amo/SC.B.asl -->

## Assembly

```asm
sc.b<.{aq, rl, f, aqrl, aqf, rlf, aqrlf}> SrcL, [SrcR], {->t, ->u, ->Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/SC.B.asl -->
```asl
readonly func InstructionContractOperation_SC_B() => ScalarOperation
begin
    return ScalarOperation_SC_B;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/SC.B.asl -->
```asl
readonly func InstructionContractHandler_SC_B() => ScalarSemanticHandler
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
