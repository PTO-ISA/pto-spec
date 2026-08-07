# HL.SETC.GEI

Execute the HL.SETC.GEI scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/bru/HL.SETC.GEI.asl -->

## Assembly

```asm
hl.setc.gei SrcL, simm
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/HL.SETC.GEI.asl -->
```asl
readonly func InstructionContractOperation_HL_SETC_GEI() => ScalarOperation
begin
    return ScalarOperation_HL_SETC_GEI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/HL.SETC.GEI.asl -->
```asl
readonly func InstructionContractHandler_HL_SETC_GEI() => ScalarSemanticHandler
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
