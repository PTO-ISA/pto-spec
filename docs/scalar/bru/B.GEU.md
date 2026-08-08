<!-- GENERATED FROM: asl/scalar/bru/B.GEU.asl -->
# B.GEU

**Normative ASL source:** `asl/scalar/bru/B.GEU.asl`

B.GEU - Conditionally branch to the PC-relative target after comparing scalar operands.

## Normative identity {#PTO-INST-SCALAR-B-GEU}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
b.geu SrcL, SrcR, label
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| b_geu_32_43a6e57dce55 | L32 | 32 | 0x00005027 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| b_geu_32_43a6e57dce55 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| b_geu_32_43a6e57dce55 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| b_geu_32_43a6e57dce55 | simm12 | 12 | signed | [{"instruction_lsb":25,"value_lsb":0,"width":7},{"instruction_lsb":7,"value_lsb":7,"width":5}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | encoded operand or control |
| SrcR | encoded operand or control |
| simm12 | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/B.GEU.asl -->
```asl
readonly func InstructionContractOperation_B_GEU() => ScalarOperation
begin
    return ScalarOperation_B_GEU;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/B.GEU.asl -->
```asl
readonly func InstructionContractHandler_B_GEU() => ScalarSemanticHandler
begin
    return ScalarHandler_BranchRelative;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `B.GEU - Conditionally branch to the PC-relative target after comparing scalar operands.`
- **Semantic handler:** `BranchRelative`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
