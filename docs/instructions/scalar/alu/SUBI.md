# SUBI

Execute the SUBI scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/SUBI.asl -->

## Assembly

```asm
subi SrcL, uimm, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/SUBI.asl -->
```asl
readonly func InstructionContractOperation_SUBI() => ScalarOperation
begin
    return ScalarOperation_SUBI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/SUBI.asl -->
```asl
readonly func InstructionContractHandler_SUBI() => ScalarSemanticHandler
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
