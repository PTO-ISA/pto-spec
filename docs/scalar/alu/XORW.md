<!-- GENERATED FROM: asl/scalar/alu/XORW.asl -->
# XORW

**Normative ASL source:** `asl/scalar/alu/XORW.asl`

XORW - Compute this mnemonic's 32-bit binary operation and sign-extend the result.

## Normative identity {#PTO-INST-SCALAR-XORW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
xorw SrcL, SrcR<{.sw,.uw,.not}><<<shamt>, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| xorw_32_32282566e32d | L32 | 32 | 0x00004025 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| xorw_32_32282566e32d | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| xorw_32_32282566e32d | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| xorw_32_32282566e32d | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| xorw_32_32282566e32d | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |
| xorw_32_32282566e32d | shamt | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | encoded operand or control |
| SrcL | encoded operand or control |
| SrcR | encoded operand or control |
| SrcRType | encoded operand or control |
| shamt | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/XORW.asl -->
```asl
readonly func InstructionContractOperation_XORW() => ScalarOperation
begin
    return ScalarOperation_XORW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/XORW.asl -->
```asl
readonly func InstructionContractHandler_XORW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `XORW - Compute this mnemonic's 32-bit binary operation and sign-extend the result.`
- **Semantic handler:** `ScalarBinaryW`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
