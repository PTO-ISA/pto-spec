<!-- GENERATED FROM: asl/scalar/bru/HL.CMP.ANDI.asl -->
# HL.CMP.ANDI

**Normative ASL source:** `asl/scalar/bru/HL.CMP.ANDI.asl`

HL.CMP.ANDI - Combine scalar comparison results with the encoded logical operation.

## Normative identity {#PTO-INST-SCALAR-HL-CMP-ANDI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
hl.cmp.andi SrcL, simm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_cmp_andi_48_de2aae3f4516 | HL48 | 48 | 0x00002055000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_cmp_andi_48_de2aae3f4516 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_cmp_andi_48_de2aae3f4516 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_cmp_andi_48_de2aae3f4516 | simm24 | 24 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | encoded operand or control |
| SrcL | encoded operand or control |
| simm24 | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/HL.CMP.ANDI.asl -->
```asl
readonly func InstructionContractOperation_HL_CMP_ANDI() => ScalarOperation
begin
    return ScalarOperation_HL_CMP_ANDI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/HL.CMP.ANDI.asl -->
```asl
readonly func InstructionContractHandler_HL_CMP_ANDI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteCompareLogical;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `HL.CMP.ANDI - Combine scalar comparison results with the encoded logical operation.`
- **Semantic handler:** `ExecuteCompareLogical`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
