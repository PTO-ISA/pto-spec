# SETC.LTUI

Execute the SETC.LTUI scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/bru/SETC.LTUI.asl -->

## Assembly

```asm
setc.ltui SrcL, uimm
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/SETC.LTUI.asl -->
```asl
readonly func InstructionContractOperation_SETC_LTUI() => ScalarOperation
begin
    return ScalarOperation_SETC_LTUI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/SETC.LTUI.asl -->
```asl
readonly func InstructionContractHandler_SETC_LTUI() => ScalarSemanticHandler
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
