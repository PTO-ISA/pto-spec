# SETC.EQ

Execute the SETC.EQ scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/bru/SETC.EQ.asl -->

## Assembly

```asm
setc.eq SrcL, SrcR<{.sw, .uw}>
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/SETC.EQ.asl -->
```asl
readonly func InstructionContractOperation_SETC_EQ() => ScalarOperation
begin
    return ScalarOperation_SETC_EQ;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/SETC.EQ.asl -->
```asl
readonly func InstructionContractHandler_SETC_EQ() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommit;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
