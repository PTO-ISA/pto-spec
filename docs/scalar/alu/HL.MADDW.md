<!-- GENERATED FROM: asl/scalar/alu/HL.MADDW.asl -->
# HL.MADDW

**Normative ASL source:** `asl/scalar/alu/HL.MADDW.asl`

HL.MADDW - Compute multiply-add and return the scalar result pair.

## Normative identity {#PTO-INST-SCALAR-HL-MADDW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
hl.maddw SrcL, SrcR, SrcD, ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_maddw_48_6fac897f0264 | HL48 | 48 | 0x00007047000e / 0x0600707f07ff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_maddw_48_6fac897f0264 | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_maddw_48_6fac897f0264 | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_maddw_48_6fac897f0264 | SrcD | 5 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":5}] |
| hl_maddw_48_6fac897f0264 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_maddw_48_6fac897f0264 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | encoded operand or control |
| RegDst1 | encoded operand or control |
| SrcD | encoded operand or control |
| SrcL | encoded operand or control |
| SrcR | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.MADDW.asl -->
```asl
readonly func InstructionContractOperation_HL_MADDW() => ScalarOperation
begin
    return ScalarOperation_HL_MADDW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.MADDW.asl -->
```asl
readonly func InstructionContractHandler_HL_MADDW() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarMultiplyAddPair;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `HL.MADDW - Compute multiply-add and return the scalar result pair.`
- **Semantic handler:** `ExecuteScalarMultiplyAddPair`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
