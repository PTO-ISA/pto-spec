<!-- GENERATED FROM: asl/scalar/alu/HL.DIVUW.asl -->
# HL.DIVUW

**Normative ASL source:** `asl/scalar/alu/HL.DIVUW.asl`

HL.DIVUW - Compute 32-bit quotient and remainder as a sign-extended result pair.

## Normative identity {#PTO-INST-SCALAR-HL-DIVUW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
hl.divuw SrcL, SrcR, ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_divuw_48_9ebe516091b8 | HL48 | 48 | 0x00003057000e / 0xfe00707f07ff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_divuw_48_9ebe516091b8 | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_divuw_48_9ebe516091b8 | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_divuw_48_9ebe516091b8 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_divuw_48_9ebe516091b8 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | encoded operand or control |
| RegDst1 | encoded operand or control |
| SrcL | encoded operand or control |
| SrcR | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.DIVUW.asl -->
```asl
readonly func InstructionContractOperation_HL_DIVUW() => ScalarOperation
begin
    return ScalarOperation_HL_DIVUW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.DIVUW.asl -->
```asl
readonly func InstructionContractHandler_HL_DIVUW() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarDividePairW;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `HL.DIVUW - Compute 32-bit quotient and remainder as a sign-extended result pair.`
- **Semantic handler:** `ExecuteScalarDividePairW`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
