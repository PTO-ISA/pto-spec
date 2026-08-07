# SUBW

Execute the SUBW scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/SUBW.asl -->

## Assembly

```asm
subw SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/SUBW.asl -->
```asl
readonly func InstructionContractOperation_SUBW() => ScalarOperation
begin
    return ScalarOperation_SUBW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/SUBW.asl -->
```asl
readonly func InstructionContractHandler_SUBW() => ScalarSemanticHandler
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
