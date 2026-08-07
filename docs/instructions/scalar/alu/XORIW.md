# XORIW

Execute the XORIW scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/XORIW.asl -->

## Assembly

```asm
xoriw SrcL, simm, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/XORIW.asl -->
```asl
readonly func InstructionContractOperation_XORIW() => ScalarOperation
begin
    return ScalarOperation_XORIW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/XORIW.asl -->
```asl
readonly func InstructionContractHandler_XORIW() => ScalarSemanticHandler
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
