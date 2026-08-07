# HL.SETC.LTI

Execute the HL.SETC.LTI scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/bru/HL.SETC.LTI.asl -->

## Assembly

```asm
hl.setc.lti SrcL, simm
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/HL.SETC.LTI.asl -->
```asl
readonly func InstructionContractOperation_HL_SETC_LTI() => ScalarOperation
begin
    return ScalarOperation_HL_SETC_LTI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/HL.SETC.LTI.asl -->
```asl
readonly func InstructionContractHandler_HL_SETC_LTI() => ScalarSemanticHandler
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
