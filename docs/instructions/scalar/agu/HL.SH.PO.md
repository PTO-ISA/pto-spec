# HL.SH.PO

Execute the HL.SH.PO scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/HL.SH.PO.asl -->

## Assembly

```asm
hl.sh.po SrcD, [SrcL, SrcR<{.sw,.uw,.neg}><<1], ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SH.PO.asl -->
```asl
readonly func InstructionContractOperation_HL_SH_PO() => ScalarOperation
begin
    return ScalarOperation_HL_SH_PO;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SH.PO.asl -->
```asl
readonly func InstructionContractHandler_HL_SH_PO() => ScalarSemanticHandler
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
