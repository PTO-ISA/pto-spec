# MAXU

Execute the MAXU scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/MAXU.asl -->

## Assembly

```asm
maxu SrcL, SrcR, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/MAXU.asl -->
```asl
readonly func InstructionContractOperation_MAXU() => ScalarOperation
begin
    return ScalarOperation_MAXU;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/MAXU.asl -->
```asl
readonly func InstructionContractHandler_MAXU() => ScalarSemanticHandler
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
