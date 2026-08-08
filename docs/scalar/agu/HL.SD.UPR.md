<!-- GENERATED FROM: asl/scalar/agu/HL.SD.UPR.asl -->
# HL.SD.UPR

**Normative ASL source:** `asl/scalar/agu/HL.SD.UPR.asl`

HL.SD.UPR - Store scalar data using this mnemonic's width and address-update form.

## Normative identity {#PTO-INST-SCALAR-HL-SD-UPR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
hl.sd.upr SrcD, [SrcL, SrcR<{.sw,.uw,.neg}>], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_sd_upr_48_af7118270a90 | HL48 | 48 | 0x00007049002e / 0x00007fff07ff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_sd_upr_48_af7118270a90 | RegDst | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_sd_upr_48_af7118270a90 | SrcD | 5 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":5}] |
| hl_sd_upr_48_af7118270a90 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_sd_upr_48_af7118270a90 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_sd_upr_48_af7118270a90 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":2}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | encoded operand or control |
| SrcD | encoded operand or control |
| SrcL | encoded operand or control |
| SrcR | encoded operand or control |
| SrcRType | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SD.UPR.asl -->
```asl
readonly func InstructionContractOperation_HL_SD_UPR() => ScalarOperation
begin
    return ScalarOperation_HL_SD_UPR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SD.UPR.asl -->
```asl
readonly func InstructionContractHandler_HL_SD_UPR() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `HL.SD.UPR - Store scalar data using this mnemonic's width and address-update form.`
- **Semantic handler:** `ExecuteScalarStore`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
