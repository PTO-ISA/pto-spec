# C.CMP.EQI

Execute the C.CMP.EQI scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/bru/C.CMP.EQI.asl -->

## Assembly

```asm
c.cmp.eqi t#1, simm, ->t
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/C.CMP.EQI.asl -->
```asl
readonly func InstructionContractOperation_C_CMP_EQI() => ScalarOperation
begin
    return ScalarOperation_C_CMP_EQI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/C.CMP.EQI.asl -->
```asl
readonly func InstructionContractHandler_C_CMP_EQI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteCompare;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
