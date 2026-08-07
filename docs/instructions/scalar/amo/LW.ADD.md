# LW.ADD

Execute the LW.ADD scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/amo/LW.ADD.asl -->

## Assembly

```asm
lw.add<.{aq, rl, f, aqrl, aqf, rlf, aqrlf}> [SrcL], SrcR, {->t, ->u, ->Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/LW.ADD.asl -->
```asl
readonly func InstructionContractOperation_LW_ADD() => ScalarOperation
begin
    return ScalarOperation_LW_ADD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/LW.ADD.asl -->
```asl
readonly func InstructionContractHandler_LW_ADD() => ScalarSemanticHandler
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
