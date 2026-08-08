<!-- GENERATED FROM: asl/scalar/alu/BIS.asl -->
# BIS

**Normative ASL source:** `asl/scalar/alu/BIS.asl`

BIS - Modify the selected scalar bitfield.

## Normative identity {#PTO-INST-SCALAR-BIS}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
bis SrcL, M, N, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bis_32_bca5d1a80f32 | L32 | 32 | 0x00003067 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bis_32_bca5d1a80f32 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| bis_32_bca5d1a80f32 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| bis_32_bca5d1a80f32 | imml | 6 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":6}] |
| bis_32_bca5d1a80f32 | imms | 6 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":6}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | encoded operand or control |
| SrcL | encoded operand or control |
| imml | encoded operand or control |
| imms | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/BIS.asl -->
```asl
readonly func InstructionContractOperation_BIS() => ScalarOperation
begin
    return ScalarOperation_BIS;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/BIS.asl -->
```asl
readonly func InstructionContractHandler_BIS() => ScalarSemanticHandler
begin
    return ScalarHandler_ModifyBitfield;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `BIS - Modify the selected scalar bitfield.`
- **Semantic handler:** `ModifyBitfield`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
