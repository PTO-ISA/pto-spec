<!-- GENERATED FROM: asl/scalar/alu/SRA.asl -->
# SRA

**Normative ASL source:** `asl/scalar/alu/SRA.asl`

SRA - Compute this mnemonic's binary scalar operation and write the selected destination.

## Normative identity {#PTO-INST-SCALAR-SRA}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
sra SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sra_32_ba03eea6386b | L32 | 32 | 0x00006005 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sra_32_ba03eea6386b | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| sra_32_ba03eea6386b | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sra_32_ba03eea6386b | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | encoded operand or control |
| SrcL | encoded operand or control |
| SrcR | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/SRA.asl -->
```asl
readonly func InstructionContractOperation_SRA() => ScalarOperation
begin
    return ScalarOperation_SRA;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/SRA.asl -->
```asl
readonly func InstructionContractHandler_SRA() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `SRA - Compute this mnemonic's binary scalar operation and write the selected destination.`
- **Semantic handler:** `ScalarBinary`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
