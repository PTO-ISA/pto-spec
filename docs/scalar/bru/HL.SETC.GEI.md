<!-- GENERATED FROM: asl/scalar/bru/HL.SETC.GEI.asl -->
# HL.SETC.GEI

**Normative ASL source:** `asl/scalar/bru/HL.SETC.GEI.asl`

HL.SETC.GEI - Compare scalar operands and update the bundle commit condition.

## Normative identity {#PTO-INST-SCALAR-HL-SETC-GEI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
hl.setc.gei SrcL, simm
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_setc_gei_48_9563d6395d06 | HL48 | 48 | 0x00005075000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_setc_gei_48_9563d6395d06 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_setc_gei_48_9563d6395d06 | shamt | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_setc_gei_48_9563d6395d06 | simm24 | 24 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | encoded operand or control |
| shamt | encoded operand or control |
| simm24 | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/HL.SETC.GEI.asl -->
```asl
readonly func InstructionContractOperation_HL_SETC_GEI() => ScalarOperation
begin
    return ScalarOperation_HL_SETC_GEI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/HL.SETC.GEI.asl -->
```asl
readonly func InstructionContractHandler_HL_SETC_GEI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommit;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `HL.SETC.GEI - Compare scalar operands and update the bundle commit condition.`
- **Semantic handler:** `ExecuteSetCommit`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
