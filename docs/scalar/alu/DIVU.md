<!-- GENERATED FROM: asl/scalar/alu/DIVU.asl -->
# DIVU

**Normative ASL source:** `asl/scalar/alu/DIVU.asl`

DIVU - Compute unsigned scalar quotient.

## Normative identity {#PTO-INST-SCALAR-DIVU}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
divu SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| divu_32_cfbc0d1760e4 | L32 | 32 | 0x00001057 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| divu_32_cfbc0d1760e4 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| divu_32_cfbc0d1760e4 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| divu_32_cfbc0d1760e4 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | encoded operand or control |
| SrcL | encoded operand or control |
| SrcR | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/DIVU.asl -->
```asl
readonly func InstructionContractOperation_DIVU() => ScalarOperation
begin
    return ScalarOperation_DIVU;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/DIVU.asl -->
```asl
readonly func InstructionContractHandler_DIVU() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarDivideUnsigned;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `DIVU - Compute unsigned scalar quotient.`
- **Semantic handler:** `ScalarDivideUnsigned`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
