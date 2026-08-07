# SRLW

Execute the SRLW scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/SRLW.asl -->

## Assembly

```asm
srlw SrcL, SrcR, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/SRLW.asl -->
```asl
readonly func InstructionContractOperation_SRLW() => ScalarOperation
begin
    return ScalarOperation_SRLW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/SRLW.asl -->
```asl
readonly func InstructionContractHandler_SRLW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
