<!-- GENERATED FROM: asl/scalar/agu/HL.SWIP.U.asl -->
# HL.SWIP.U

**Normative ASL source:** `asl/scalar/agu/HL.SWIP.U.asl`

HL.SWIP.U - Store a scalar register pair using this mnemonic's address-update form.

## Normative identity {#PTO-INST-SCALAR-HL-SWIP-U}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
hl.swip.u SrcD, SrcD1, [SrcR, simm]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_swip_u_48_e2dc917c8505 | HL48 | 48 | 0x00006059001e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_swip_u_48_e2dc917c8505 | SrcD | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_swip_u_48_e2dc917c8505 | SrcD1 | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |
| hl_swip_u_48_e2dc917c8505 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_swip_u_48_e2dc917c8505 | simm17 | 17 | signed | [{"instruction_lsb":41,"value_lsb":0,"width":7},{"instruction_lsb":23,"value_lsb":7,"width":5},{"instruction_lsb":11,"value_lsb":12,"width":5}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcD | encoded operand or control |
| SrcD1 | encoded operand or control |
| SrcR | encoded operand or control |
| simm17 | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SWIP.U.asl -->
```asl
readonly func InstructionContractOperation_HL_SWIP_U() => ScalarOperation
begin
    return ScalarOperation_HL_SWIP_U;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SWIP.U.asl -->
```asl
readonly func InstructionContractHandler_HL_SWIP_U() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStorePair;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `HL.SWIP.U - Store a scalar register pair using this mnemonic's address-update form.`
- **Semantic handler:** `ExecuteScalarStorePair`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
