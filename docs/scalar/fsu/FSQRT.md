<!-- GENERATED FROM: asl/scalar/fsu/FSQRT.asl -->
# FSQRT

**Normative ASL source:** `asl/scalar/fsu/FSQRT.asl`

FSQRT - Compute this mnemonic's unary floating-point operation.

## Normative identity {#PTO-INST-SCALAR-FSQRT}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
fsqrt.{T} SrcL, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| fsqrt_32_84b3495cc6c7 | L32 | 32 | 0x0000107b / 0xf9f0707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| fsqrt_32_84b3495cc6c7 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| fsqrt_32_84b3495cc6c7 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| fsqrt_32_84b3495cc6c7 | SrcType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | encoded operand or control |
| SrcL | encoded operand or control |
| SrcType | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/FSQRT.asl -->
```asl
readonly func InstructionContractOperation_FSQRT() => ScalarOperation
begin
    return ScalarOperation_FSQRT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/FSQRT.asl -->
```asl
readonly func InstructionContractHandler_FSQRT() => ScalarSemanticHandler
begin
    return ScalarHandler_FloatingUnary;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `FSQRT - Compute this mnemonic's unary floating-point operation.`
- **Semantic handler:** `FloatingUnary`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
