# C.ZEXT.W

Execute the C.ZEXT.W scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/C.ZEXT.W.asl -->

## Assembly

```asm
c.zext.w srcL, ->t
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/C.ZEXT.W.asl -->
```asl
readonly func InstructionContractOperation_C_ZEXT_W() => ScalarOperation
begin
    return ScalarOperation_C_ZEXT_W;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/C.ZEXT.W.asl -->
```asl
readonly func InstructionContractHandler_C_ZEXT_W() => ScalarSemanticHandler
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
