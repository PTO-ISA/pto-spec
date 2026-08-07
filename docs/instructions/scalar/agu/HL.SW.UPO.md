# HL.SW.UPO

Execute the HL.SW.UPO scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/HL.SW.UPO.asl -->

## Assembly

```asm
hl.sw.upo SrcD, [SrcL, SrcR<{.sw,.uw,.neg}>], ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SW.UPO.asl -->
```asl
readonly func InstructionContractOperation_HL_SW_UPO() => ScalarOperation
begin
    return ScalarOperation_HL_SW_UPO;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SW.UPO.asl -->
```asl
readonly func InstructionContractHandler_HL_SW_UPO() => ScalarSemanticHandler
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
