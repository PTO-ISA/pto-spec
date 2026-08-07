# C.LWI

Execute the C.LWI scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/C.LWI.asl -->

## Assembly

```asm
c.lwi [srcL, simm], ->t
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/C.LWI.asl -->
```asl
readonly func InstructionContractOperation_C_LWI() => ScalarOperation
begin
    return ScalarOperation_C_LWI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/C.LWI.asl -->
```asl
readonly func InstructionContractHandler_C_LWI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
