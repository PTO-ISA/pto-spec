<!-- GENERATED FROM: asl/scalar/alu/BIC.asl -->
# BIC

**Normative ASL source:** `asl/scalar/alu/BIC.asl`

BIC - Modify the selected scalar bitfield.

## Normative identity {#PTO-INST-SCALAR-BIC}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
bic SrcL, M, N, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bic_32_3a10830a3a93 | L32 | 32 | 0x00002067 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bic_32_3a10830a3a93 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| bic_32_3a10830a3a93 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| bic_32_3a10830a3a93 | imml | 6 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":6}] |
| bic_32_3a10830a3a93 | imms | 6 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":6}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | encoded operand or control |
| SrcL | encoded operand or control |
| imml | encoded operand or control |
| imms | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/BIC.asl -->
```asl
readonly func InstructionContractOperation_BIC() => ScalarOperation
begin
    return ScalarOperation_BIC;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/BIC.asl -->
```asl
readonly func InstructionContractHandler_BIC() => ScalarSemanticHandler
begin
    return ScalarHandler_ModifyBitfield;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `BIC - Modify the selected scalar bitfield.`
- **Semantic handler:** `ModifyBitfield`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
