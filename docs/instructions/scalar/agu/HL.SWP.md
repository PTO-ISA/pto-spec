# HL.SWP

Execute the HL.SWP scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/HL.SWP.asl -->

## Assembly

```asm
hl.swp SrcD, SrcD1, [SrcL, SrcR<{.sw,.uw,.neg}><<2]
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SWP.asl -->
```asl
readonly func InstructionContractOperation_HL_SWP() => ScalarOperation
begin
    return ScalarOperation_HL_SWP;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SWP.asl -->
```asl
readonly func InstructionContractHandler_HL_SWP() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStorePair;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
