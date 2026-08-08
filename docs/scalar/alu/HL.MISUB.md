<!-- GENERATED FROM: asl/scalar/alu/HL.MISUB.asl -->
# HL.MISUB

**Normative ASL source:** `asl/scalar/alu/HL.MISUB.asl`

HL.MISUB - Multiply by the encoded immediate and add the scalar source.

## Normative identity {#PTO-INST-SCALAR-HL-MISUB}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
hl.misub SrcL, SrcR, uimm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_misub_48_e9e4c7b23479 | HL48 | 48 | 0x0000104d000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_misub_48_e9e4c7b23479 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_misub_48_e9e4c7b23479 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_misub_48_e9e4c7b23479 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_misub_48_e9e4c7b23479 | uimm19 | 19 | unsigned | [{"instruction_lsb":41,"value_lsb":0,"width":7},{"instruction_lsb":4,"value_lsb":7,"width":12}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | encoded operand or control |
| SrcL | encoded operand or control |
| SrcR | encoded operand or control |
| uimm19 | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.MISUB.asl -->
```asl
readonly func InstructionContractOperation_HL_MISUB() => ScalarOperation
begin
    return ScalarOperation_HL_MISUB;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.MISUB.asl -->
```asl
readonly func InstructionContractHandler_HL_MISUB() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarMultiplyImmediateAdd;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `HL.MISUB - Multiply by the encoded immediate and add the scalar source.`
- **Semantic handler:** `ScalarMultiplyImmediateAdd`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
