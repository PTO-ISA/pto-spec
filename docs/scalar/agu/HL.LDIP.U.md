<!-- GENERATED FROM: asl/scalar/agu/HL.LDIP.U.asl -->
# HL.LDIP.U

**Normative ASL source:** `asl/scalar/agu/HL.LDIP.U.asl`

HL.LDIP.U - Load a scalar register pair using this mnemonic's address-update form.

## Normative identity {#PTO-INST-SCALAR-HL-LDIP-U}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
hl.ldip.u [SrcL, simm], ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_ldip_u_48_6813f4fdce5c | HL48 | 48 | 0x00003029001e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_ldip_u_48_6813f4fdce5c | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_ldip_u_48_6813f4fdce5c | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_ldip_u_48_6813f4fdce5c | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_ldip_u_48_6813f4fdce5c | simm17 | 17 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":6,"value_lsb":12,"width":5}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | encoded operand or control |
| RegDst1 | encoded operand or control |
| SrcL | encoded operand or control |
| simm17 | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LDIP.U.asl -->
```asl
readonly func InstructionContractOperation_HL_LDIP_U() => ScalarOperation
begin
    return ScalarOperation_HL_LDIP_U;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LDIP.U.asl -->
```asl
readonly func InstructionContractHandler_HL_LDIP_U() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoadPair;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `HL.LDIP.U - Load a scalar register pair using this mnemonic's address-update form.`
- **Semantic handler:** `ExecuteScalarLoadPair`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
