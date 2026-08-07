# SRAIW

Execute the SRAIW scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/SRAIW.asl -->

## Assembly

```asm
sraiw SrcL, shamt, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/SRAIW.asl -->
```asl
readonly func InstructionContractOperation_SRAIW() => ScalarOperation
begin
    return ScalarOperation_SRAIW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/SRAIW.asl -->
```asl
readonly func InstructionContractHandler_SRAIW() => ScalarSemanticHandler
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
