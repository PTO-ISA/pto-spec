<!-- GENERATED FROM: asl/scalar/bru/CMP.NE.asl -->
# CMP.NE

**Normative ASL source:** `asl/scalar/bru/CMP.NE.asl`

CMP.NE - Compare scalar operands and write the encoded boolean result.

## Normative identity {#PTO-INST-SCALAR-CMP-NE}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
cmp.ne SrcL, SrcR<{.sw, .uw}>, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| cmp_ne_32_fc47fbb1a0de | L32 | 32 | 0x00001045 / 0xf800707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| cmp_ne_32_fc47fbb1a0de | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| cmp_ne_32_fc47fbb1a0de | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| cmp_ne_32_fc47fbb1a0de | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| cmp_ne_32_fc47fbb1a0de | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | encoded operand or control |
| SrcL | encoded operand or control |
| SrcR | encoded operand or control |
| SrcRType | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/CMP.NE.asl -->
```asl
readonly func InstructionContractOperation_CMP_NE() => ScalarOperation
begin
    return ScalarOperation_CMP_NE;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/CMP.NE.asl -->
```asl
readonly func InstructionContractHandler_CMP_NE() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteCompare;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `CMP.NE - Compare scalar operands and write the encoded boolean result.`
- **Semantic handler:** `ExecuteCompare`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
