<!-- GENERATED FROM: asl/scalar/fsu/FCVTZ.asl -->
# FCVTZ

**Normative ASL source:** `asl/scalar/fsu/FCVTZ.asl`

FCVTZ - Convert between the encoded scalar numeric formats.

## Normative identity {#PTO-INST-SCALAR-FCVTZ}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
fcvtz.{srcT2dstT} SrcL, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| fcvtz_32_bee01d31217c | L32 | 32 | 0x0000506b / 0x01f0707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| fcvtz_32_bee01d31217c | DstType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| fcvtz_32_bee01d31217c | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| fcvtz_32_bee01d31217c | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| fcvtz_32_bee01d31217c | SrcType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| DstType | encoded operand or control |
| RegDst | encoded operand or control |
| SrcL | encoded operand or control |
| SrcType | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/FCVTZ.asl -->
```asl
readonly func InstructionContractOperation_FCVTZ() => ScalarOperation
begin
    return ScalarOperation_FCVTZ;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/FCVTZ.asl -->
```asl
readonly func InstructionContractHandler_FCVTZ() => ScalarSemanticHandler
begin
    return ScalarHandler_ConvertFloatingEncoding;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `FCVTZ - Convert between the encoded scalar numeric formats.`
- **Semantic handler:** `ConvertFloatingEncoding`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
