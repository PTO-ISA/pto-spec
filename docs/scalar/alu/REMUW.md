<!-- GENERATED FROM: asl/scalar/alu/REMUW.asl -->
# REMUW

**Normative ASL source:** `asl/scalar/alu/REMUW.asl`

REMUW - Compute unsigned 32-bit remainder and sign-extend it.

## Normative identity {#PTO-INST-SCALAR-REMUW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
remuw SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| remuw_32_f10ade2f5ccb | L32 | 32 | 0x00007057 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| remuw_32_f10ade2f5ccb | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| remuw_32_f10ade2f5ccb | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| remuw_32_f10ade2f5ccb | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | encoded operand or control |
| SrcL | encoded operand or control |
| SrcR | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/REMUW.asl -->
```asl
readonly func InstructionContractOperation_REMUW() => ScalarOperation
begin
    return ScalarOperation_REMUW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/REMUW.asl -->
```asl
readonly func InstructionContractHandler_REMUW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarRemainderUnsignedW;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `REMUW - Compute unsigned 32-bit remainder and sign-extend it.`
- **Semantic handler:** `ScalarRemainderUnsignedW`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
