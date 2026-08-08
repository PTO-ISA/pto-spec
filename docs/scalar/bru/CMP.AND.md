<!-- GENERATED FROM: asl/scalar/bru/CMP.AND.asl -->
# CMP.AND

**Normative ASL source:** `asl/scalar/bru/CMP.AND.asl`

CMP.AND - Combine scalar comparison results with the encoded logical operation.

## Normative identity {#PTO-INST-SCALAR-CMP-AND}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
cmp.and SrcL, SrcR<.sw, .uw, .not>, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| cmp_and_32_036813a12ae8 | L32 | 32 | 0x00002045 / 0xf800707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| cmp_and_32_036813a12ae8 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| cmp_and_32_036813a12ae8 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| cmp_and_32_036813a12ae8 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| cmp_and_32_036813a12ae8 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | encoded operand or control |
| SrcL | encoded operand or control |
| SrcR | encoded operand or control |
| SrcRType | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/CMP.AND.asl -->
```asl
readonly func InstructionContractOperation_CMP_AND() => ScalarOperation
begin
    return ScalarOperation_CMP_AND;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/CMP.AND.asl -->
```asl
readonly func InstructionContractHandler_CMP_AND() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteCompareLogical;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `CMP.AND - Combine scalar comparison results with the encoded logical operation.`
- **Semantic handler:** `ExecuteCompareLogical`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
