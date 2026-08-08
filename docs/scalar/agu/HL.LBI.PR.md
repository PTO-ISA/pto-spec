<!-- GENERATED FROM: asl/scalar/agu/HL.LBI.PR.asl -->
# HL.LBI.PR

**Normative ASL source:** `asl/scalar/agu/HL.LBI.PR.asl`

HL.LBI.PR - Load scalar data using this mnemonic's width, signedness, and address-update form.

## Normative identity {#PTO-INST-SCALAR-HL-LBI-PR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
hl.lbi.pr [SrcL, simm], ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lbi_pr_48_b4bdbd29f859 | HL48 | 48 | 0x00000019002e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lbi_pr_48_b4bdbd29f859 | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lbi_pr_48_b4bdbd29f859 | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_lbi_pr_48_b4bdbd29f859 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_lbi_pr_48_b4bdbd29f859 | simm17 | 17 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":6,"value_lsb":12,"width":5}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | encoded operand or control |
| RegDst1 | encoded operand or control |
| SrcL | encoded operand or control |
| simm17 | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LBI.PR.asl -->
```asl
readonly func InstructionContractOperation_HL_LBI_PR() => ScalarOperation
begin
    return ScalarOperation_HL_LBI_PR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LBI.PR.asl -->
```asl
readonly func InstructionContractHandler_HL_LBI_PR() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `HL.LBI.PR - Load scalar data using this mnemonic's width, signedness, and address-update form.`
- **Semantic handler:** `ExecuteScalarLoad`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
