<!-- GENERATED FROM: asl/scalar/agu/HL.SHI.UPR.asl -->
# HL.SHI.UPR

**Normative ASL source:** `asl/scalar/agu/HL.SHI.UPR.asl`

HL.SHI.UPR - Store scalar data using this mnemonic's width and address-update form.

## Normative identity {#PTO-INST-SCALAR-HL-SHI-UPR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
hl.shi.upr SrcD, [SrcR, simm], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_shi_upr_48_ca9f1acbb1b2 | HL48 | 48 | 0x00005059002e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_shi_upr_48_ca9f1acbb1b2 | RegDst | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_shi_upr_48_ca9f1acbb1b2 | SrcD | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_shi_upr_48_ca9f1acbb1b2 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_shi_upr_48_ca9f1acbb1b2 | simm17 | 17 | signed | [{"instruction_lsb":41,"value_lsb":0,"width":7},{"instruction_lsb":23,"value_lsb":7,"width":5},{"instruction_lsb":6,"value_lsb":12,"width":5}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | encoded operand or control |
| SrcD | encoded operand or control |
| SrcR | encoded operand or control |
| simm17 | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SHI.UPR.asl -->
```asl
readonly func InstructionContractOperation_HL_SHI_UPR() => ScalarOperation
begin
    return ScalarOperation_HL_SHI_UPR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SHI.UPR.asl -->
```asl
readonly func InstructionContractHandler_HL_SHI_UPR() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `HL.SHI.UPR - Store scalar data using this mnemonic's width and address-update form.`
- **Semantic handler:** `ExecuteScalarStore`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
