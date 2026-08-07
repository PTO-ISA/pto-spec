# SRLI

Execute the SRLI scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/SRLI.asl -->

## Assembly

```asm
srli SrcL, shamt, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/SRLI.asl -->
```asl
readonly func InstructionContractOperation_SRLI() => ScalarOperation
begin
    return ScalarOperation_SRLI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/SRLI.asl -->
```asl
readonly func InstructionContractHandler_SRLI() => ScalarSemanticHandler
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
