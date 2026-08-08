<!-- GENERATED FROM: asl/scalar/bru/CMP.ORI.asl -->
# CMP.ORI

**Normative ASL source:** `asl/scalar/bru/CMP.ORI.asl`

CMP.ORI - Combine scalar comparison results with the encoded logical operation.

## Normative identity {#PTO-INST-SCALAR-CMP-ORI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
cmp.ori SrcL, simm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| cmp_ori_32_6d3efbc3d093 | L32 | 32 | 0x00003055 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| cmp_ori_32_6d3efbc3d093 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| cmp_ori_32_6d3efbc3d093 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| cmp_ori_32_6d3efbc3d093 | simm12 | 12 | signed | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | encoded operand or control |
| SrcL | encoded operand or control |
| simm12 | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/CMP.ORI.asl -->
```asl
readonly func InstructionContractOperation_CMP_ORI() => ScalarOperation
begin
    return ScalarOperation_CMP_ORI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/CMP.ORI.asl -->
```asl
readonly func InstructionContractHandler_CMP_ORI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteCompareLogical;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `CMP.ORI - Combine scalar comparison results with the encoded logical operation.`
- **Semantic handler:** `ExecuteCompareLogical`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
