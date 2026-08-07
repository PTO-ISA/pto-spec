# HL.SWI.UPO

Execute the HL.SWI.UPO scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/HL.SWI.UPO.asl -->

## Assembly

```asm
hl.swi.upo SrcD, [SrcR, simm], ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SWI.UPO.asl -->
```asl
readonly func InstructionContractOperation_HL_SWI_UPO() => ScalarOperation
begin
    return ScalarOperation_HL_SWI_UPO;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SWI.UPO.asl -->
```asl
readonly func InstructionContractHandler_HL_SWI_UPO() => ScalarSemanticHandler
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
