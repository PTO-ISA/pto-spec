<!-- GENERATED FROM: asl/scalar/fsu/FRECIP.asl -->
# FRECIP

**Normative ASL source:** `asl/scalar/fsu/FRECIP.asl`

FRECIP - Compute this mnemonic's unary floating-point operation.

## Normative identity {#PTO-INST-SCALAR-FRECIP}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
frecip.{T} SrcL, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| frecip_32_3d51f4f727ea | L32 | 32 | 0x0000207b / 0xf9f0707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| frecip_32_3d51f4f727ea | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| frecip_32_3d51f4f727ea | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| frecip_32_3d51f4f727ea | SrcType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | encoded operand or control |
| SrcL | encoded operand or control |
| SrcType | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/FRECIP.asl -->
```asl
readonly func InstructionContractOperation_FRECIP() => ScalarOperation
begin
    return ScalarOperation_FRECIP;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/FRECIP.asl -->
```asl
readonly func InstructionContractHandler_FRECIP() => ScalarSemanticHandler
begin
    return ScalarHandler_FloatingUnary;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `FRECIP - Compute this mnemonic's unary floating-point operation.`
- **Semantic handler:** `FloatingUnary`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
