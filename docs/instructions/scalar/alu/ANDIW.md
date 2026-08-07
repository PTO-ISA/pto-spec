# ANDIW

Execute the ANDIW scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/ANDIW.asl -->

## Assembly

```asm
andiw SrcL, simm, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/ANDIW.asl -->
```asl
readonly func InstructionContractOperation_ANDIW() => ScalarOperation
begin
    return ScalarOperation_ANDIW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/ANDIW.asl -->
```asl
readonly func InstructionContractHandler_ANDIW() => ScalarSemanticHandler
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
