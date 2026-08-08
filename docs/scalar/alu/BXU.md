<!-- GENERATED FROM: asl/scalar/alu/BXU.asl -->
# BXU

**Normative ASL source:** `asl/scalar/alu/BXU.asl`

BXU - Extract the selected scalar bitfield.

## Normative identity {#PTO-INST-SCALAR-BXU}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
bxu SrcL, M, N, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bxu_32_e9ea9715ba62 | L32 | 32 | 0x00001067 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bxu_32_e9ea9715ba62 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| bxu_32_e9ea9715ba62 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| bxu_32_e9ea9715ba62 | imml | 6 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":6}] |
| bxu_32_e9ea9715ba62 | imms | 6 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":6}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | encoded operand or control |
| SrcL | encoded operand or control |
| imml | encoded operand or control |
| imms | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/BXU.asl -->
```asl
readonly func InstructionContractOperation_BXU() => ScalarOperation
begin
    return ScalarOperation_BXU;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/BXU.asl -->
```asl
readonly func InstructionContractHandler_BXU() => ScalarSemanticHandler
begin
    return ScalarHandler_ExtractBitfield;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `BXU - Extract the selected scalar bitfield.`
- **Semantic handler:** `ExtractBitfield`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
