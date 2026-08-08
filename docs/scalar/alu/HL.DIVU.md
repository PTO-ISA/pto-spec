<!-- GENERATED FROM: asl/scalar/alu/HL.DIVU.asl -->
# HL.DIVU

**Normative ASL source:** `asl/scalar/alu/HL.DIVU.asl`

HL.DIVU - Compute quotient and remainder as a scalar result pair.

## Normative identity {#PTO-INST-SCALAR-HL-DIVU}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
hl.divu SrcL, SrcR, ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_divu_48_597acda29e08 | HL48 | 48 | 0x00001057000e / 0xfe00707f07ff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_divu_48_597acda29e08 | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_divu_48_597acda29e08 | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_divu_48_597acda29e08 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_divu_48_597acda29e08 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | encoded operand or control |
| RegDst1 | encoded operand or control |
| SrcL | encoded operand or control |
| SrcR | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.DIVU.asl -->
```asl
readonly func InstructionContractOperation_HL_DIVU() => ScalarOperation
begin
    return ScalarOperation_HL_DIVU;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.DIVU.asl -->
```asl
readonly func InstructionContractHandler_HL_DIVU() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarDividePair;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `HL.DIVU - Compute quotient and remainder as a scalar result pair.`
- **Semantic handler:** `ExecuteScalarDividePair`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
