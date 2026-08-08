<!-- GENERATED FROM: asl/scalar/alu/DIV.asl -->
# DIV

**Normative ASL source:** `asl/scalar/alu/DIV.asl`

DIV - Compute signed scalar quotient.

## Normative identity {#PTO-INST-SCALAR-DIV}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
div SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| div_32_a6efe85f8662 | L32 | 32 | 0x00000057 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| div_32_a6efe85f8662 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| div_32_a6efe85f8662 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| div_32_a6efe85f8662 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | encoded operand or control |
| SrcL | encoded operand or control |
| SrcR | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/DIV.asl -->
```asl
readonly func InstructionContractOperation_DIV() => ScalarOperation
begin
    return ScalarOperation_DIV;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/DIV.asl -->
```asl
readonly func InstructionContractHandler_DIV() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarDivideSigned;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `DIV - Compute signed scalar quotient.`
- **Semantic handler:** `ScalarDivideSigned`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
