<!-- GENERATED FROM: asl/scalar/alu/SLLIW.asl -->
# SLLIW

**Normative ASL source:** `asl/scalar/alu/SLLIW.asl`

SLLIW - Compute this mnemonic's 32-bit binary operation and sign-extend the result.

## Normative identity {#PTO-INST-SCALAR-SLLIW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
slliw SrcL, shamt, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| slliw_32_c6bf463b97ae | L32 | 32 | 0x00007035 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| slliw_32_c6bf463b97ae | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| slliw_32_c6bf463b97ae | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| slliw_32_c6bf463b97ae | shamt | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | encoded operand or control |
| SrcL | encoded operand or control |
| shamt | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/SLLIW.asl -->
```asl
readonly func InstructionContractOperation_SLLIW() => ScalarOperation
begin
    return ScalarOperation_SLLIW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/SLLIW.asl -->
```asl
readonly func InstructionContractHandler_SLLIW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `SLLIW - Compute this mnemonic's 32-bit binary operation and sign-extend the result.`
- **Semantic handler:** `ScalarBinaryW`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
