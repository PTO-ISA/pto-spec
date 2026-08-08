<!-- GENERATED FROM: asl/scalar/alu/CSEL.asl -->
# CSEL

**Normative ASL source:** `asl/scalar/alu/CSEL.asl`

CSEL - Select one of two scalar inputs under the encoded condition.

## Normative identity {#PTO-INST-SCALAR-CSEL}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
csel SrcP, SrcL, SrcR<.neg>, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| csel_32_ba77cbad3c99 | L32 | 32 | 0x00000077 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| csel_32_ba77cbad3c99 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| csel_32_ba77cbad3c99 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| csel_32_ba77cbad3c99 | SrcP | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| csel_32_ba77cbad3c99 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| csel_32_ba77cbad3c99 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | encoded operand or control |
| SrcL | encoded operand or control |
| SrcP | encoded operand or control |
| SrcR | encoded operand or control |
| SrcRType | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/CSEL.asl -->
```asl
readonly func InstructionContractOperation_CSEL() => ScalarOperation
begin
    return ScalarOperation_CSEL;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/CSEL.asl -->
```asl
readonly func InstructionContractHandler_CSEL() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarConditionalSelect;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `CSEL - Select one of two scalar inputs under the encoded condition.`
- **Semantic handler:** `ScalarConditionalSelect`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
