<!-- GENERATED FROM: asl/scalar/fsu/FNMSUB.asl -->
# FNMSUB

**Normative ASL source:** `asl/scalar/fsu/FNMSUB.asl`

FNMSUB - Compute this mnemonic's fused floating-point operation.

## Normative identity {#PTO-INST-SCALAR-FNMSUB}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
fnmsub.{T} SrcL, SrcR, SrcA, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| fnmsub_32_6542d56665b3 | L32 | 32 | 0x0000704b / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| fnmsub_32_6542d56665b3 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| fnmsub_32_6542d56665b3 | SrcA | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| fnmsub_32_6542d56665b3 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| fnmsub_32_6542d56665b3 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| fnmsub_32_6542d56665b3 | SrcType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | encoded operand or control |
| SrcA | encoded operand or control |
| SrcL | encoded operand or control |
| SrcR | encoded operand or control |
| SrcType | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/FNMSUB.asl -->
```asl
readonly func InstructionContractOperation_FNMSUB() => ScalarOperation
begin
    return ScalarOperation_FNMSUB;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/FNMSUB.asl -->
```asl
readonly func InstructionContractHandler_FNMSUB() => ScalarSemanticHandler
begin
    return ScalarHandler_FloatingFused;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `FNMSUB - Compute this mnemonic's fused floating-point operation.`
- **Semantic handler:** `FloatingFused`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
