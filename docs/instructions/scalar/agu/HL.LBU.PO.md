# HL.LBU.PO

Execute the HL.LBU.PO scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/HL.LBU.PO.asl -->

## Assembly

```asm
hl.lbu.po [SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>], ->Dst0, Dst1
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LBU.PO.asl -->
```asl
readonly func InstructionContractOperation_HL_LBU_PO() => ScalarOperation
begin
    return ScalarOperation_HL_LBU_PO;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LBU.PO.asl -->
```asl
readonly func InstructionContractHandler_HL_LBU_PO() => ScalarSemanticHandler
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
