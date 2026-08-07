# C.SWI

Execute the C.SWI scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/C.SWI.asl -->

## Assembly

```asm
c.swi t#1, [srcL, simm]
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/C.SWI.asl -->
```asl
readonly func InstructionContractOperation_C_SWI() => ScalarOperation
begin
    return ScalarOperation_C_SWI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/C.SWI.asl -->
```asl
readonly func InstructionContractHandler_C_SWI() => ScalarSemanticHandler
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
