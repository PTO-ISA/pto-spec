# SETC.GEI

Execute the SETC.GEI scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/bru/SETC.GEI.asl -->

## Assembly

```asm
setc.gei SrcL, simm
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/SETC.GEI.asl -->
```asl
readonly func InstructionContractOperation_SETC_GEI() => ScalarOperation
begin
    return ScalarOperation_SETC_GEI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/SETC.GEI.asl -->
```asl
readonly func InstructionContractHandler_SETC_GEI() => ScalarSemanticHandler
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
