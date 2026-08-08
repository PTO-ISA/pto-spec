<!-- GENERATED FROM: asl/scalar/bru/HL.CMP.GEUI.asl -->
# HL.CMP.GEUI

**Normative ASL source:** `asl/scalar/bru/HL.CMP.GEUI.asl`

HL.CMP.GEUI - Compare scalar operands and write the encoded boolean result.

## Normative identity {#PTO-INST-SCALAR-HL-CMP-GEUI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
hl.cmp.geui SrcL, uimm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_cmp_geui_48_c71f4fb29e6b | HL48 | 48 | 0x00007055000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_cmp_geui_48_c71f4fb29e6b | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_cmp_geui_48_c71f4fb29e6b | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_cmp_geui_48_c71f4fb29e6b | uimm24 | 24 | unsigned | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | encoded operand or control |
| SrcL | encoded operand or control |
| uimm24 | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/HL.CMP.GEUI.asl -->
```asl
readonly func InstructionContractOperation_HL_CMP_GEUI() => ScalarOperation
begin
    return ScalarOperation_HL_CMP_GEUI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/HL.CMP.GEUI.asl -->
```asl
readonly func InstructionContractHandler_HL_CMP_GEUI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteCompare;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `HL.CMP.GEUI - Compare scalar operands and write the encoded boolean result.`
- **Semantic handler:** `ExecuteCompare`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
