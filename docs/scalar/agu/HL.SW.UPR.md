<!-- GENERATED FROM: asl/scalar/agu/HL.SW.UPR.asl -->
# HL.SW.UPR

**Normative ASL source:** `asl/scalar/agu/HL.SW.UPR.asl`

HL.SW.UPR - Store scalar data using this mnemonic's width and address-update form.

## Normative identity {#PTO-INST-SCALAR-HL-SW-UPR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
hl.sw.upr SrcD, [SrcL, SrcR<{.sw,.uw,.neg}>], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_sw_upr_48_d4ccb513944a | HL48 | 48 | 0x00006049002e / 0x00007fff07ff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_sw_upr_48_d4ccb513944a | RegDst | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_sw_upr_48_d4ccb513944a | SrcD | 5 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":5}] |
| hl_sw_upr_48_d4ccb513944a | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_sw_upr_48_d4ccb513944a | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_sw_upr_48_d4ccb513944a | SrcRType | 2 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":2}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | encoded operand or control |
| SrcD | encoded operand or control |
| SrcL | encoded operand or control |
| SrcR | encoded operand or control |
| SrcRType | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SW.UPR.asl -->
```asl
readonly func InstructionContractOperation_HL_SW_UPR() => ScalarOperation
begin
    return ScalarOperation_HL_SW_UPR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SW.UPR.asl -->
```asl
readonly func InstructionContractHandler_HL_SW_UPR() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `HL.SW.UPR - Store scalar data using this mnemonic's width and address-update form.`
- **Semantic handler:** `ExecuteScalarStore`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
