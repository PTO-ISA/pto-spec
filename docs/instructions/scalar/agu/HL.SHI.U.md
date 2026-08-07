# HL.SHI.U

Execute the HL.SHI.U scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/HL.SHI.U.asl -->

## Assembly

```asm
hl.shi.u SrcD, [SrcR, simm]
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SHI.U.asl -->
```asl
readonly func InstructionContractOperation_HL_SHI_U() => ScalarOperation
begin
    return ScalarOperation_HL_SHI_U;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SHI.U.asl -->
```asl
readonly func InstructionContractHandler_HL_SHI_U() => ScalarSemanticHandler
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
