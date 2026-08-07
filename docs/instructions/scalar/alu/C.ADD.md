# C.ADD

Execute the C.ADD scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/C.ADD.asl -->

## Assembly

```asm
c.add srcL, srcR, ->t
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/C.ADD.asl -->
```asl
readonly func InstructionContractOperation_C_ADD() => ScalarOperation
begin
    return ScalarOperation_C_ADD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/C.ADD.asl -->
```asl
readonly func InstructionContractHandler_C_ADD() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
