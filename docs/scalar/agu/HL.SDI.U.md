<!-- GENERATED FROM: asl/scalar/agu/HL.SDI.U.asl -->
# HL.SDI.U

**Normative ASL source:** `asl/scalar/agu/HL.SDI.U.asl`

HL.SDI.U - Store scalar data using this mnemonic's width and address-update form.

## Normative identity {#PTO-INST-SCALAR-HL-SDI-U}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
hl.sdi.u SrcD, [SrcR, simm]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_sdi_u_48_d9597eeba6b4 | HL48 | 48 | 0x00007059000e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_sdi_u_48_d9597eeba6b4 | SrcD | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_sdi_u_48_d9597eeba6b4 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_sdi_u_48_d9597eeba6b4 | simm22 | 22 | signed | [{"instruction_lsb":41,"value_lsb":0,"width":7},{"instruction_lsb":23,"value_lsb":7,"width":5},{"instruction_lsb":6,"value_lsb":12,"width":10}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcD | encoded operand or control |
| SrcR | encoded operand or control |
| simm22 | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SDI.U.asl -->
```asl
readonly func InstructionContractOperation_HL_SDI_U() => ScalarOperation
begin
    return ScalarOperation_HL_SDI_U;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SDI.U.asl -->
```asl
readonly func InstructionContractHandler_HL_SDI_U() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `HL.SDI.U - Store scalar data using this mnemonic's width and address-update form.`
- **Semantic handler:** `ExecuteScalarStore`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
