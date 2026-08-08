<!-- GENERATED FROM: asl/scalar/alu/HL.CCATW.asl -->
# HL.CCATW

**Normative ASL source:** `asl/scalar/alu/HL.CCATW.asl`

HL.CCATW - Concatenate two 32-bit values into a sign-extended result pair.

## Normative identity {#PTO-INST-SCALAR-HL-CCATW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
hl.ccatw SrcL, SrcR, shamt, ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_ccatw_48_24a85ea4659c | HL48 | 48 | 0x0000205d000e / 0x0000707f07ff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_ccatw_48_24a85ea4659c | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_ccatw_48_24a85ea4659c | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_ccatw_48_24a85ea4659c | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_ccatw_48_24a85ea4659c | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_ccatw_48_24a85ea4659c | shamt | 7 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":7}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | encoded operand or control |
| RegDst1 | encoded operand or control |
| SrcL | encoded operand or control |
| SrcR | encoded operand or control |
| shamt | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.CCATW.asl -->
```asl
readonly func InstructionContractOperation_HL_CCATW() => ScalarOperation
begin
    return ScalarOperation_HL_CCATW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.CCATW.asl -->
```asl
readonly func InstructionContractHandler_HL_CCATW() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteConcatenatePairW;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `HL.CCATW - Concatenate two 32-bit values into a sign-extended result pair.`
- **Semantic handler:** `ExecuteConcatenatePairW`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
