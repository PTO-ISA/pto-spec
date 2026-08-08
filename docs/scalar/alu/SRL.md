<!-- GENERATED FROM: asl/scalar/alu/SRL.asl -->
# SRL

**Normative ASL source:** `asl/scalar/alu/SRL.asl`

SRL - Compute this mnemonic's binary scalar operation and write the selected destination.

## Normative identity {#PTO-INST-SCALAR-SRL}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
srl SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| srl_32_5cfca42c59f3 | L32 | 32 | 0x00005005 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| srl_32_5cfca42c59f3 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| srl_32_5cfca42c59f3 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| srl_32_5cfca42c59f3 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | encoded operand or control |
| SrcL | encoded operand or control |
| SrcR | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/SRL.asl -->
```asl
readonly func InstructionContractOperation_SRL() => ScalarOperation
begin
    return ScalarOperation_SRL;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/SRL.asl -->
```asl
readonly func InstructionContractHandler_SRL() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `SRL - Compute this mnemonic's binary scalar operation and write the selected destination.`
- **Semantic handler:** `ScalarBinary`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
