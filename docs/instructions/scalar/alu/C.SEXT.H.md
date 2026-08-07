# C.SEXT.H

Execute the C.SEXT.H scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/C.SEXT.H.asl -->

## Assembly

```asm
c.sext.h srcL, ->t
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/C.SEXT.H.asl -->
```asl
readonly func InstructionContractOperation_C_SEXT_H() => ScalarOperation
begin
    return ScalarOperation_C_SEXT_H;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/C.SEXT.H.asl -->
```asl
readonly func InstructionContractHandler_C_SEXT_H() => ScalarSemanticHandler
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
