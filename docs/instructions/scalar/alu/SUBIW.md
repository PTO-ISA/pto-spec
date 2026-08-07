# SUBIW

Execute the SUBIW scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/SUBIW.asl -->

## Assembly

```asm
subiw SrcL, uimm, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/SUBIW.asl -->
```asl
readonly func InstructionContractOperation_SUBIW() => ScalarOperation
begin
    return ScalarOperation_SUBIW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/SUBIW.asl -->
```asl
readonly func InstructionContractHandler_SUBIW() => ScalarSemanticHandler
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
