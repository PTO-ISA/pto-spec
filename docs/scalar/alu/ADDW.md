<!-- GENERATED FROM: asl/scalar/alu/ADDW.asl -->
# ADDW

**Normative ASL source:** `asl/scalar/alu/ADDW.asl`

ADDW - Compute this mnemonic's 32-bit binary operation and sign-extend the result.

## Normative identity {#PTO-INST-SCALAR-ADDW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
addw SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| addw_32_a27109fe30fc | L32 | 32 | 0x00000025 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| addw_32_a27109fe30fc | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| addw_32_a27109fe30fc | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| addw_32_a27109fe30fc | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| addw_32_a27109fe30fc | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |
| addw_32_a27109fe30fc | shamt | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | encoded operand or control |
| SrcL | encoded operand or control |
| SrcR | encoded operand or control |
| SrcRType | encoded operand or control |
| shamt | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/ADDW.asl -->
```asl
readonly func InstructionContractOperation_ADDW() => ScalarOperation
begin
    return ScalarOperation_ADDW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/ADDW.asl -->
```asl
readonly func InstructionContractHandler_ADDW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `ADDW - Compute this mnemonic's 32-bit binary operation and sign-extend the result.`
- **Semantic handler:** `ScalarBinaryW`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
