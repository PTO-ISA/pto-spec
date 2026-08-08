<!-- GENERATED FROM: asl/scalar/fsu/FMUL.asl -->
# FMUL

**Normative ASL source:** `asl/scalar/fsu/FMUL.asl`

FMUL - Compute this mnemonic's binary floating-point operation.

## Normative identity {#PTO-INST-SCALAR-FMUL}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
fmul.{T} SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| fmul_32_7d521d9d65e7 | L32 | 32 | 0x0000204b / 0xf800707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| fmul_32_7d521d9d65e7 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| fmul_32_7d521d9d65e7 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| fmul_32_7d521d9d65e7 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| fmul_32_7d521d9d65e7 | SrcType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | encoded operand or control |
| SrcL | encoded operand or control |
| SrcR | encoded operand or control |
| SrcType | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/FMUL.asl -->
```asl
readonly func InstructionContractOperation_FMUL() => ScalarOperation
begin
    return ScalarOperation_FMUL;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/FMUL.asl -->
```asl
readonly func InstructionContractHandler_FMUL() => ScalarSemanticHandler
begin
    return ScalarHandler_FloatingBinary;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `FMUL - Compute this mnemonic's binary floating-point operation.`
- **Semantic handler:** `FloatingBinary`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
