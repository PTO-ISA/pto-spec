# DIVU

Execute the DIVU scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/DIVU.asl -->

## Assembly

```asm
divu SrcL, SrcR, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/DIVU.asl -->
```asl
readonly func InstructionContractOperation_DIVU() => ScalarOperation
begin
    return ScalarOperation_DIVU;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/DIVU.asl -->
```asl
readonly func InstructionContractHandler_DIVU() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarDivideUnsigned;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
