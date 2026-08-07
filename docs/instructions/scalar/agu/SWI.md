# SWI

Execute the SWI scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/SWI.asl -->

## Assembly

```asm
swi SrcL, [SrcR, simm]
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/SWI.asl -->
```asl
readonly func InstructionContractOperation_SWI() => ScalarOperation
begin
    return ScalarOperation_SWI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/SWI.asl -->
```asl
readonly func InstructionContractHandler_SWI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
