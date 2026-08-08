<!-- GENERATED FROM: asl/scalar/bru/B.LT.asl -->
# B.LT

**Normative ASL source:** `asl/scalar/bru/B.LT.asl`

B.LT - Conditionally branch to the PC-relative target after comparing scalar operands.

## Normative identity {#PTO-INST-SCALAR-B-LT}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
b.lt SrcL, SrcR, label
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| b_lt_32_2ca5ecd25cfb | L32 | 32 | 0x00002027 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| b_lt_32_2ca5ecd25cfb | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| b_lt_32_2ca5ecd25cfb | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| b_lt_32_2ca5ecd25cfb | simm12 | 12 | signed | [{"instruction_lsb":25,"value_lsb":0,"width":7},{"instruction_lsb":7,"value_lsb":7,"width":5}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | encoded operand or control |
| SrcR | encoded operand or control |
| simm12 | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/B.LT.asl -->
```asl
readonly func InstructionContractOperation_B_LT() => ScalarOperation
begin
    return ScalarOperation_B_LT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/B.LT.asl -->
```asl
readonly func InstructionContractHandler_B_LT() => ScalarSemanticHandler
begin
    return ScalarHandler_BranchRelative;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `B.LT - Conditionally branch to the PC-relative target after comparing scalar operands.`
- **Semantic handler:** `BranchRelative`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
