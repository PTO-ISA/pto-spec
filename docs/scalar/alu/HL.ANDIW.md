<!-- GENERATED FROM: asl/scalar/alu/HL.ANDIW.asl -->
# HL.ANDIW

**Normative ASL source:** `asl/scalar/alu/HL.ANDIW.asl`

HL.ANDIW - Compute this mnemonic's 32-bit binary operation and sign-extend the result.

## Normative identity {#PTO-INST-SCALAR-HL-ANDIW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
hl.andiw SrcL, simm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_andiw_48_878c6594c6ff | HL48 | 48 | 0x00002035000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_andiw_48_878c6594c6ff | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_andiw_48_878c6594c6ff | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_andiw_48_878c6594c6ff | simm24 | 24 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | encoded operand or control |
| SrcL | encoded operand or control |
| simm24 | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.ANDIW.asl -->
```asl
readonly func InstructionContractOperation_HL_ANDIW() => ScalarOperation
begin
    return ScalarOperation_HL_ANDIW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.ANDIW.asl -->
```asl
readonly func InstructionContractHandler_HL_ANDIW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `HL.ANDIW - Compute this mnemonic's 32-bit binary operation and sign-extend the result.`
- **Semantic handler:** `ScalarBinaryW`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
