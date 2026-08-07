# SETC.LTI

Execute the SETC.LTI scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/bru/SETC.LTI.asl -->

## Assembly

```asm
setc.lti SrcL, simm
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/SETC.LTI.asl -->
```asl
readonly func InstructionContractOperation_SETC_LTI() => ScalarOperation
begin
    return ScalarOperation_SETC_LTI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/SETC.LTI.asl -->
```asl
readonly func InstructionContractHandler_SETC_LTI() => ScalarSemanticHandler
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
