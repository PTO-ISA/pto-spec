# C.SEXT.B

Execute the C.SEXT.B scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/C.SEXT.B.asl -->

## Assembly

```asm
c.sext.b srcL, ->t
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/C.SEXT.B.asl -->
```asl
readonly func InstructionContractOperation_C_SEXT_B() => ScalarOperation
begin
    return ScalarOperation_C_SEXT_B;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/C.SEXT.B.asl -->
```asl
readonly func InstructionContractHandler_C_SEXT_B() => ScalarSemanticHandler
begin
    return ScalarHandler_ExtendScalarValue;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
