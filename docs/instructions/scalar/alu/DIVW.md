# DIVW

Execute the DIVW scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/DIVW.asl -->

## Assembly

```asm
divw SrcL, SrcR, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/DIVW.asl -->
```asl
readonly func InstructionContractOperation_DIVW() => ScalarOperation
begin
    return ScalarOperation_DIVW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/DIVW.asl -->
```asl
readonly func InstructionContractHandler_DIVW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarDivideSignedW;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
