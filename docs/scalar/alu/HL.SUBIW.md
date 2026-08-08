<!-- GENERATED FROM: asl/scalar/alu/HL.SUBIW.asl -->
# HL.SUBIW

**Normative ASL source:** `asl/scalar/alu/HL.SUBIW.asl`

HL.SUBIW - Compute this mnemonic's 32-bit binary operation and sign-extend the result.

## Normative identity {#PTO-INST-SCALAR-HL-SUBIW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
hl.subiw SrcL, uimm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_subiw_48_adc7b127a2f8 | HL48 | 48 | 0x00001035000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_subiw_48_adc7b127a2f8 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_subiw_48_adc7b127a2f8 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_subiw_48_adc7b127a2f8 | uimm24 | 24 | unsigned | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | encoded operand or control |
| SrcL | encoded operand or control |
| uimm24 | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.SUBIW.asl -->
```asl
readonly func InstructionContractOperation_HL_SUBIW() => ScalarOperation
begin
    return ScalarOperation_HL_SUBIW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.SUBIW.asl -->
```asl
readonly func InstructionContractHandler_HL_SUBIW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `HL.SUBIW - Compute this mnemonic's 32-bit binary operation and sign-extend the result.`
- **Semantic handler:** `ScalarBinaryW`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
