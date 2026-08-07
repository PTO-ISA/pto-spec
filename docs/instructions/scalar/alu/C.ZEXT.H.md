# C.ZEXT.H

Execute the C.ZEXT.H scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/C.ZEXT.H.asl -->

## Assembly

```asm
c.zext.h srcL, ->t
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/C.ZEXT.H.asl -->
```asl
readonly func InstructionContractOperation_C_ZEXT_H() => ScalarOperation
begin
    return ScalarOperation_C_ZEXT_H;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/C.ZEXT.H.asl -->
```asl
readonly func InstructionContractHandler_C_ZEXT_H() => ScalarSemanticHandler
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
