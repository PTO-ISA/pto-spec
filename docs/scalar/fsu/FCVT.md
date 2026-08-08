<!-- GENERATED FROM: asl/scalar/fsu/FCVT.asl -->
# FCVT

**Normative ASL source:** `asl/scalar/fsu/FCVT.asl`

FCVT - Convert between the encoded scalar numeric formats.

## Normative identity {#PTO-INST-SCALAR-FCVT}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
fcvt.{srcT2dstT} SrcL, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| fcvt_32_1102f5aeeda9 | L32 | 32 | 0x0000006b / 0x01f0707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| fcvt_32_1102f5aeeda9 | DstType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| fcvt_32_1102f5aeeda9 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| fcvt_32_1102f5aeeda9 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| fcvt_32_1102f5aeeda9 | SrcType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| DstType | encoded operand or control |
| RegDst | encoded operand or control |
| SrcL | encoded operand or control |
| SrcType | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/FCVT.asl -->
```asl
readonly func InstructionContractOperation_FCVT() => ScalarOperation
begin
    return ScalarOperation_FCVT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/FCVT.asl -->
```asl
readonly func InstructionContractHandler_FCVT() => ScalarSemanticHandler
begin
    return ScalarHandler_ConvertFloatingEncoding;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `FCVT - Convert between the encoded scalar numeric formats.`
- **Semantic handler:** `ConvertFloatingEncoding`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
