<!-- GENERATED FROM: asl/scalar/agu/LHU.asl -->
# LHU

**Normative ASL source:** `asl/scalar/agu/LHU.asl`

LHU - Load scalar data using this mnemonic's width, signedness, and address-update form.

## Normative identity {#PTO-INST-SCALAR-LHU}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
lhu [SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| lhu_32_730caf67ecd1 | L32 | 32 | 0x00005009 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| lhu_32_730caf67ecd1 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| lhu_32_730caf67ecd1 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| lhu_32_730caf67ecd1 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| lhu_32_730caf67ecd1 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |
| lhu_32_730caf67ecd1 | shamt | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | encoded operand or control |
| SrcL | encoded operand or control |
| SrcR | encoded operand or control |
| SrcRType | encoded operand or control |
| shamt | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/LHU.asl -->
```asl
readonly func InstructionContractOperation_LHU() => ScalarOperation
begin
    return ScalarOperation_LHU;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/LHU.asl -->
```asl
readonly func InstructionContractHandler_LHU() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `LHU - Load scalar data using this mnemonic's width, signedness, and address-update form.`
- **Semantic handler:** `ExecuteScalarLoad`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
