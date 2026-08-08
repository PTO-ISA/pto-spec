<!-- GENERATED FROM: asl/scalar/alu/REMW.asl -->
# REMW

**Normative ASL source:** `asl/scalar/alu/REMW.asl`

REMW - Compute signed 32-bit remainder and sign-extend it.

## Normative identity {#PTO-INST-SCALAR-REMW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
remw SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| remw_32_22659af46ec0 | L32 | 32 | 0x00006057 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| remw_32_22659af46ec0 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| remw_32_22659af46ec0 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| remw_32_22659af46ec0 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | encoded operand or control |
| SrcL | encoded operand or control |
| SrcR | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/REMW.asl -->
```asl
readonly func InstructionContractOperation_REMW() => ScalarOperation
begin
    return ScalarOperation_REMW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/REMW.asl -->
```asl
readonly func InstructionContractHandler_REMW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarRemainderSignedW;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `REMW - Compute signed 32-bit remainder and sign-extend it.`
- **Semantic handler:** `ScalarRemainderSignedW`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
