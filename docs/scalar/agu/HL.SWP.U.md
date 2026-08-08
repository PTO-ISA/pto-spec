<!-- GENERATED FROM: asl/scalar/agu/HL.SWP.U.asl -->
# HL.SWP.U

**Normative ASL source:** `asl/scalar/agu/HL.SWP.U.asl`

HL.SWP.U - Store a scalar register pair using this mnemonic's address-update form.

## Normative identity {#PTO-INST-SCALAR-HL-SWP-U}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
hl.swp.u SrcD, SrcD1, [SrcL, SrcR<{.sw,.uw,.neg}>]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_swp_u_48_c244a576be8e | HL48 | 48 | 0x00006049001e / 0x00007ffff83f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_swp_u_48_c244a576be8e | SrcD | 5 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":5}] |
| hl_swp_u_48_c244a576be8e | SrcD1 | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |
| hl_swp_u_48_c244a576be8e | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_swp_u_48_c244a576be8e | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_swp_u_48_c244a576be8e | SrcRType | 2 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":2}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcD | encoded operand or control |
| SrcD1 | encoded operand or control |
| SrcL | encoded operand or control |
| SrcR | encoded operand or control |
| SrcRType | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SWP.U.asl -->
```asl
readonly func InstructionContractOperation_HL_SWP_U() => ScalarOperation
begin
    return ScalarOperation_HL_SWP_U;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SWP.U.asl -->
```asl
readonly func InstructionContractHandler_HL_SWP_U() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStorePair;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `HL.SWP.U - Store a scalar register pair using this mnemonic's address-update form.`
- **Semantic handler:** `ExecuteScalarStorePair`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
