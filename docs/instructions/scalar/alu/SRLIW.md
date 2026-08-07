# SRLIW

Execute the SRLIW scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/SRLIW.asl -->

## Assembly

```asm
srliw SrcL, shamt, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/SRLIW.asl -->
```asl
readonly func InstructionContractOperation_SRLIW() => ScalarOperation
begin
    return ScalarOperation_SRLIW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/SRLIW.asl -->
```asl
readonly func InstructionContractHandler_SRLIW() => ScalarSemanticHandler
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
