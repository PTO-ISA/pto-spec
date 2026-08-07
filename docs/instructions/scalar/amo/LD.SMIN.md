# LD.SMIN

Execute the LD.SMIN scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/amo/LD.SMIN.asl -->

## Assembly

```asm
ld.smin<.{aq, rl, f, aqrl, aqf, rlf, aqrlf}> [SrcL], SrcR, {->t, ->u, ->Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/LD.SMIN.asl -->
```asl
readonly func InstructionContractOperation_LD_SMIN() => ScalarOperation
begin
    return ScalarOperation_LD_SMIN;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/LD.SMIN.asl -->
```asl
readonly func InstructionContractHandler_LD_SMIN() => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
