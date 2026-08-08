<!-- GENERATED FROM: asl/scalar/fsu/FEXP.asl -->
# FEXP

**Normative ASL source:** `asl/scalar/fsu/FEXP.asl`

FEXP - Compute this mnemonic's unary floating-point operation.

## Normative identity {#PTO-INST-SCALAR-FEXP}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
fexp.{T} SrcL, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| fexp_32_592ef5288c7d | L32 | 32 | 0x0000307b / 0xf9f0707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| fexp_32_592ef5288c7d | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| fexp_32_592ef5288c7d | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| fexp_32_592ef5288c7d | SrcType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | encoded operand or control |
| SrcL | encoded operand or control |
| SrcType | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/FEXP.asl -->
```asl
readonly func InstructionContractOperation_FEXP() => ScalarOperation
begin
    return ScalarOperation_FEXP;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/FEXP.asl -->
```asl
readonly func InstructionContractHandler_FEXP() => ScalarSemanticHandler
begin
    return ScalarHandler_FloatingUnary;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `FEXP - Compute this mnemonic's unary floating-point operation.`
- **Semantic handler:** `FloatingUnary`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
