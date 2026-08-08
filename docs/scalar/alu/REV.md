<!-- GENERATED FROM: asl/scalar/alu/REV.asl -->
# REV

**Normative ASL source:** `asl/scalar/alu/REV.asl`

REV - Reverse bytes within the selected scalar bitfield.

## Normative identity {#PTO-INST-SCALAR-REV}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
rev SrcL,  M, N, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| rev_32_58badc109d49 | L32 | 32 | 0x00007067 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| rev_32_58badc109d49 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| rev_32_58badc109d49 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| rev_32_58badc109d49 | imml | 6 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":6}] |
| rev_32_58badc109d49 | immr | 6 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":6}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | encoded operand or control |
| SrcL | encoded operand or control |
| imml | encoded operand or control |
| immr | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/REV.asl -->
```asl
readonly func InstructionContractOperation_REV() => ScalarOperation
begin
    return ScalarOperation_REV;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/REV.asl -->
```asl
readonly func InstructionContractHandler_REV() => ScalarSemanticHandler
begin
    return ScalarHandler_ReverseBitfieldBytes;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `REV - Reverse bytes within the selected scalar bitfield.`
- **Semantic handler:** `ReverseBitfieldBytes`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
