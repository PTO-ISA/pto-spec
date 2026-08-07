# CSEL

Execute the CSEL scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/CSEL.asl -->

## Assembly

```asm
csel SrcP, SrcL, SrcR<.neg>, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/CSEL.asl -->
```asl
readonly func InstructionContractOperation_CSEL() => ScalarOperation
begin
    return ScalarOperation_CSEL;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/CSEL.asl -->
```asl
readonly func InstructionContractHandler_CSEL() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarConditionalSelect;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
