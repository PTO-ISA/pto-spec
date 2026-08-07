# HL.SHI

Execute the HL.SHI scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/HL.SHI.asl -->

## Assembly

```asm
hl.shi SrcD, [SrcR, simm]
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SHI.asl -->
```asl
readonly func InstructionContractOperation_HL_SHI() => ScalarOperation
begin
    return ScalarOperation_HL_SHI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SHI.asl -->
```asl
readonly func InstructionContractHandler_HL_SHI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
