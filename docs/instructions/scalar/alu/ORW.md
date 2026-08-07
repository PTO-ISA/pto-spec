# ORW

Execute the ORW scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/ORW.asl -->

## Assembly

```asm
orw SrcL, SrcR<{.sw,.uw,.not}><<<shamt>, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/ORW.asl -->
```asl
readonly func InstructionContractOperation_ORW() => ScalarOperation
begin
    return ScalarOperation_ORW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/ORW.asl -->
```asl
readonly func InstructionContractHandler_ORW() => ScalarSemanticHandler
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
