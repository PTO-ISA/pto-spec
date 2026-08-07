# C.SRLI

Execute the C.SRLI scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/C.SRLI.asl -->

## Assembly

```asm
c.srli t#1, uimm, ->t
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/C.SRLI.asl -->
```asl
readonly func InstructionContractOperation_C_SRLI() => ScalarOperation
begin
    return ScalarOperation_C_SRLI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/C.SRLI.asl -->
```asl
readonly func InstructionContractHandler_C_SRLI() => ScalarSemanticHandler
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
