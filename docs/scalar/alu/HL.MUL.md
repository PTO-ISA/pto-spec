<!-- GENERATED FROM: asl/scalar/alu/HL.MUL.asl -->
# HL.MUL

**Normative ASL source:** `asl/scalar/alu/HL.MUL.asl`

HL.MUL - Compute the full-width scalar product as a result pair.

## Normative identity {#PTO-INST-SCALAR-HL-MUL}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
hl.mul SrcL, SrcR, ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_mul_48_0d059ff178fb | HL48 | 48 | 0x00000047000e / 0xfe00707f07ff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_mul_48_0d059ff178fb | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_mul_48_0d059ff178fb | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_mul_48_0d059ff178fb | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_mul_48_0d059ff178fb | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | encoded operand or control |
| RegDst1 | encoded operand or control |
| SrcL | encoded operand or control |
| SrcR | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.MUL.asl -->
```asl
readonly func InstructionContractOperation_HL_MUL() => ScalarOperation
begin
    return ScalarOperation_HL_MUL;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.MUL.asl -->
```asl
readonly func InstructionContractHandler_HL_MUL() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarMultiplyPair;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `HL.MUL - Compute the full-width scalar product as a result pair.`
- **Semantic handler:** `ExecuteScalarMultiplyPair`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
