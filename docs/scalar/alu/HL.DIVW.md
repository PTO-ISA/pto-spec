<!-- GENERATED FROM: asl/scalar/alu/HL.DIVW.asl -->
# HL.DIVW

**Normative ASL source:** `asl/scalar/alu/HL.DIVW.asl`

HL.DIVW - Compute 32-bit quotient and remainder as a sign-extended result pair.

## Normative identity {#PTO-INST-SCALAR-HL-DIVW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
hl.divw SrcL, SrcR, ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_divw_48_9048cdb3b22f | HL48 | 48 | 0x00002057000e / 0xfe00707f07ff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_divw_48_9048cdb3b22f | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_divw_48_9048cdb3b22f | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_divw_48_9048cdb3b22f | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_divw_48_9048cdb3b22f | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | encoded operand or control |
| RegDst1 | encoded operand or control |
| SrcL | encoded operand or control |
| SrcR | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.DIVW.asl -->
```asl
readonly func InstructionContractOperation_HL_DIVW() => ScalarOperation
begin
    return ScalarOperation_HL_DIVW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.DIVW.asl -->
```asl
readonly func InstructionContractHandler_HL_DIVW() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarDividePairW;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `HL.DIVW - Compute 32-bit quotient and remainder as a sign-extended result pair.`
- **Semantic handler:** `ExecuteScalarDividePairW`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
