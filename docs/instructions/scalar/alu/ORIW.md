# ORIW

Execute the ORIW scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/ORIW.asl -->

## Assembly

```asm
oriw SrcL, simm, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/ORIW.asl -->
```asl
readonly func InstructionContractOperation_ORIW() => ScalarOperation
begin
    return ScalarOperation_ORIW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/ORIW.asl -->
```asl
readonly func InstructionContractHandler_ORIW() => ScalarSemanticHandler
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
