<!-- GENERATED FROM: asl/scalar/alu/HL.REMU.asl -->
# HL.REMU

**Normative ASL source:** `asl/scalar/alu/HL.REMU.asl`

HL.REMU - Compute quotient and remainder as a scalar result pair.

## Normative identity {#PTO-INST-SCALAR-HL-REMU}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
hl.remu SrcL, SrcR, ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_remu_48_3bf4e5a663c1 | HL48 | 48 | 0x00005057000e / 0xfe00707f07ff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_remu_48_3bf4e5a663c1 | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_remu_48_3bf4e5a663c1 | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_remu_48_3bf4e5a663c1 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_remu_48_3bf4e5a663c1 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | encoded operand or control |
| RegDst1 | encoded operand or control |
| SrcL | encoded operand or control |
| SrcR | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.REMU.asl -->
```asl
readonly func InstructionContractOperation_HL_REMU() => ScalarOperation
begin
    return ScalarOperation_HL_REMU;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.REMU.asl -->
```asl
readonly func InstructionContractHandler_HL_REMU() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarDividePair;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `HL.REMU - Compute quotient and remainder as a scalar result pair.`
- **Semantic handler:** `ExecuteScalarDividePair`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
