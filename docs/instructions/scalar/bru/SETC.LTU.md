# SETC.LTU

Execute the SETC.LTU scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/bru/SETC.LTU.asl -->

## Assembly

```asm
setc.ltu SrcL, SrcR<{.sw, .uw}>
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/SETC.LTU.asl -->
```asl
readonly func InstructionContractOperation_SETC_LTU() => ScalarOperation
begin
    return ScalarOperation_SETC_LTU;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/SETC.LTU.asl -->
```asl
readonly func InstructionContractHandler_SETC_LTU() => ScalarSemanticHandler
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
