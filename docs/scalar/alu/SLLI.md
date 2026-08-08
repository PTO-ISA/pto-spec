<!-- GENERATED FROM: asl/scalar/alu/SLLI.asl -->
# SLLI

**Normative ASL source:** `asl/scalar/alu/SLLI.asl`

SLLI - Compute this mnemonic's binary scalar operation and write the selected destination.

## Normative identity {#PTO-INST-SCALAR-SLLI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
slli SrcL, shamt, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| slli_32_b43ca2454e3a | L32 | 32 | 0x00007015 / 0xfc00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| slli_32_b43ca2454e3a | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| slli_32_b43ca2454e3a | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| slli_32_b43ca2454e3a | shamt | 6 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":6}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | encoded operand or control |
| SrcL | encoded operand or control |
| shamt | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/SLLI.asl -->
```asl
readonly func InstructionContractOperation_SLLI() => ScalarOperation
begin
    return ScalarOperation_SLLI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/SLLI.asl -->
```asl
readonly func InstructionContractHandler_SLLI() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `SLLI - Compute this mnemonic's binary scalar operation and write the selected destination.`
- **Semantic handler:** `ScalarBinary`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
