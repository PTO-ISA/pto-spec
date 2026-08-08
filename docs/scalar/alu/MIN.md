<!-- GENERATED FROM: asl/scalar/alu/MIN.asl -->
# MIN

**Normative ASL source:** `asl/scalar/alu/MIN.asl`

MIN - Compute this mnemonic's binary scalar operation and write the selected destination.

## Normative identity {#PTO-INST-SCALAR-MIN}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
min SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| min_32_25692b799267 | L32 | 32 | 0x0000505b / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| min_32_25692b799267 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| min_32_25692b799267 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| min_32_25692b799267 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | encoded operand or control |
| SrcL | encoded operand or control |
| SrcR | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/MIN.asl -->
```asl
readonly func InstructionContractOperation_MIN() => ScalarOperation
begin
    return ScalarOperation_MIN;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/MIN.asl -->
```asl
readonly func InstructionContractHandler_MIN() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `MIN - Compute this mnemonic's binary scalar operation and write the selected destination.`
- **Semantic handler:** `ScalarBinary`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
