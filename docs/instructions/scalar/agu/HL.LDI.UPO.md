# HL.LDI.UPO

Execute the HL.LDI.UPO scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/HL.LDI.UPO.asl -->

## Assembly

```asm
hl.ldi.upo [SrcL, simm], ->Dst0, Dst1
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LDI.UPO.asl -->
```asl
readonly func InstructionContractOperation_HL_LDI_UPO() => ScalarOperation
begin
    return ScalarOperation_HL_LDI_UPO;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LDI.UPO.asl -->
```asl
readonly func InstructionContractHandler_HL_LDI_UPO() => ScalarSemanticHandler
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
