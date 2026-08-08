<!-- GENERATED FROM: asl/scalar/agu/HL.LHIP.asl -->
# HL.LHIP

**Normative ASL source:** `asl/scalar/agu/HL.LHIP.asl`

HL.LHIP - Load a scalar register pair using this mnemonic's address-update form.

## Normative identity {#PTO-INST-SCALAR-HL-LHIP}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
hl.lhip [SrcL, simm], ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lhip_48_2c664751c537 | HL48 | 48 | 0x00001019001e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lhip_48_2c664751c537 | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lhip_48_2c664751c537 | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_lhip_48_2c664751c537 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_lhip_48_2c664751c537 | simm17 | 17 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":6,"value_lsb":12,"width":5}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | encoded operand or control |
| RegDst1 | encoded operand or control |
| SrcL | encoded operand or control |
| simm17 | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LHIP.asl -->
```asl
readonly func InstructionContractOperation_HL_LHIP() => ScalarOperation
begin
    return ScalarOperation_HL_LHIP;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LHIP.asl -->
```asl
readonly func InstructionContractHandler_HL_LHIP() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoadPair;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `HL.LHIP - Load a scalar register pair using this mnemonic's address-update form.`
- **Semantic handler:** `ExecuteScalarLoadPair`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
