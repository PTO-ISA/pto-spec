# HL.LB.PO

Execute the HL.LB.PO scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/HL.LB.PO.asl -->

## Assembly

```asm
hl.lb.po [SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>], ->Dst0, Dst1
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LB.PO.asl -->
```asl
readonly func InstructionContractOperation_HL_LB_PO() => ScalarOperation
begin
    return ScalarOperation_HL_LB_PO;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LB.PO.asl -->
```asl
readonly func InstructionContractHandler_HL_LB_PO() => ScalarSemanticHandler
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
