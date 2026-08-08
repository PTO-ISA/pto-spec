<!-- GENERATED FROM: asl/scalar/sys/FENCE.D.asl -->
# FENCE.D

**Normative ASL source:** `asl/scalar/sys/FENCE.D.asl`

FENCE.D - Order the selected predecessor and successor data-access classes.

## Normative identity {#PTO-INST-SCALAR-FENCE-D}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
fence.d pred_imm, succ_imm
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| fence_d_32_f4783f17d84d | L32 | 32 | 0x0000202b / 0xf00fffff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| fence_d_32_f4783f17d84d | PRED_IMM | 4 | encoding-defined | [{"instruction_lsb":24,"value_lsb":0,"width":4}] |
| fence_d_32_f4783f17d84d | SUCC_IMM | 4 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":4}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| PRED_IMM | encoded operand or control |
| SUCC_IMM | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/FENCE.D.asl -->
```asl
readonly func InstructionContractOperation_FENCE_D() => ScalarOperation
begin
    return ScalarOperation_FENCE_D;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/FENCE.D.asl -->
```asl
readonly func InstructionContractHandler_FENCE_D() => ScalarSemanticHandler
begin
    return ScalarHandler_FenceData;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `FENCE.D - Order the selected predecessor and successor data-access classes.`
- **Semantic handler:** `FenceData`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
