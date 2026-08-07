# HL.LWI.UPO

Execute the HL.LWI.UPO scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/HL.LWI.UPO.asl -->

## Assembly

```asm
hl.lwi.upo [SrcL, simm], ->Dst0, Dst1
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LWI.UPO.asl -->
```asl
readonly func InstructionContractOperation_HL_LWI_UPO() => ScalarOperation
begin
    return ScalarOperation_HL_LWI_UPO;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LWI.UPO.asl -->
```asl
readonly func InstructionContractHandler_HL_LWI_UPO() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
