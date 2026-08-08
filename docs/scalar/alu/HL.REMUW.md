<!-- GENERATED FROM: asl/scalar/alu/HL.REMUW.asl -->
# HL.REMUW

**Normative ASL source:** `asl/scalar/alu/HL.REMUW.asl`

HL.REMUW - Compute 32-bit quotient and remainder as a sign-extended result pair.

## Normative identity {#PTO-INST-SCALAR-HL-REMUW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
hl.remuw SrcL, SrcR, ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_remuw_48_26ea6e70f2fc | HL48 | 48 | 0x00007057000e / 0xfe00707f07ff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_remuw_48_26ea6e70f2fc | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_remuw_48_26ea6e70f2fc | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_remuw_48_26ea6e70f2fc | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_remuw_48_26ea6e70f2fc | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | encoded operand or control |
| RegDst1 | encoded operand or control |
| SrcL | encoded operand or control |
| SrcR | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.REMUW.asl -->
```asl
readonly func InstructionContractOperation_HL_REMUW() => ScalarOperation
begin
    return ScalarOperation_HL_REMUW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.REMUW.asl -->
```asl
readonly func InstructionContractHandler_HL_REMUW() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarDividePairW;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `HL.REMUW - Compute 32-bit quotient and remainder as a sign-extended result pair.`
- **Semantic handler:** `ExecuteScalarDividePairW`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
