<!-- GENERATED FROM: asl/scalar/alu/ORI.asl -->
# ORI

**Normative ASL source:** `asl/scalar/alu/ORI.asl`

ORI - Compute this mnemonic's binary scalar operation and write the selected destination.

## Normative identity {#PTO-INST-SCALAR-ORI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
ori SrcL, simm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| ori_32_413a6cc76e9a | L32 | 32 | 0x00003015 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| ori_32_413a6cc76e9a | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| ori_32_413a6cc76e9a | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| ori_32_413a6cc76e9a | simm12 | 12 | signed | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | encoded operand or control |
| SrcL | encoded operand or control |
| simm12 | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/ORI.asl -->
```asl
readonly func InstructionContractOperation_ORI() => ScalarOperation
begin
    return ScalarOperation_ORI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/ORI.asl -->
```asl
readonly func InstructionContractHandler_ORI() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `ORI - Compute this mnemonic's binary scalar operation and write the selected destination.`
- **Semantic handler:** `ScalarBinary`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
