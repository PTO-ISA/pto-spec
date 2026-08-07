# SETC.EQI

Execute the SETC.EQI scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/bru/SETC.EQI.asl -->

## Assembly

```asm
setc.eqi SrcL, simm
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/SETC.EQI.asl -->
```asl
readonly func InstructionContractOperation_SETC_EQI() => ScalarOperation
begin
    return ScalarOperation_SETC_EQI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/SETC.EQI.asl -->
```asl
readonly func InstructionContractHandler_SETC_EQI() => ScalarSemanticHandler
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
