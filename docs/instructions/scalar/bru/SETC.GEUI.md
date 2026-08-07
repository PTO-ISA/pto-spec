# SETC.GEUI

Execute the SETC.GEUI scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/bru/SETC.GEUI.asl -->

## Assembly

```asm
setc.geui SrcL, uimm
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/SETC.GEUI.asl -->
```asl
readonly func InstructionContractOperation_SETC_GEUI() => ScalarOperation
begin
    return ScalarOperation_SETC_GEUI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/SETC.GEUI.asl -->
```asl
readonly func InstructionContractHandler_SETC_GEUI() => ScalarSemanticHandler
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
