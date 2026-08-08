<!-- GENERATED FROM: asl/scalar/alu/HL.REMW.asl -->
# HL.REMW

**Normative ASL source:** `asl/scalar/alu/HL.REMW.asl`

HL.REMW - Compute 32-bit quotient and remainder as a sign-extended result pair.

## Normative identity {#PTO-INST-SCALAR-HL-REMW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
hl.remw SrcL, SrcR, ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_remw_48_3acb485d39a7 | HL48 | 48 | 0x00006057000e / 0xfe00707f07ff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_remw_48_3acb485d39a7 | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_remw_48_3acb485d39a7 | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_remw_48_3acb485d39a7 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_remw_48_3acb485d39a7 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | encoded operand or control |
| RegDst1 | encoded operand or control |
| SrcL | encoded operand or control |
| SrcR | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.REMW.asl -->
```asl
readonly func InstructionContractOperation_HL_REMW() => ScalarOperation
begin
    return ScalarOperation_HL_REMW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.REMW.asl -->
```asl
readonly func InstructionContractHandler_HL_REMW() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarDividePairW;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `HL.REMW - Compute 32-bit quotient and remainder as a sign-extended result pair.`
- **Semantic handler:** `ExecuteScalarDividePairW`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
