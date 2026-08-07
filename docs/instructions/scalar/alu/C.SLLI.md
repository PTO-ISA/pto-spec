# C.SLLI

Execute the C.SLLI scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/C.SLLI.asl -->

## Assembly

```asm
c.slli t#1, uimm, ->t
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/C.SLLI.asl -->
```asl
readonly func InstructionContractOperation_C_SLLI() => ScalarOperation
begin
    return ScalarOperation_C_SLLI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/C.SLLI.asl -->
```asl
readonly func InstructionContractHandler_C_SLLI() => ScalarSemanticHandler
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
