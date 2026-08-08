<!-- GENERATED FROM: asl/scalar/bru/SETC.AND.asl -->
# SETC.AND

**Normative ASL source:** `asl/scalar/bru/SETC.AND.asl`

SETC.AND - Combine scalar comparison results and update the bundle commit condition.

## Normative identity {#PTO-INST-SCALAR-SETC-AND}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
setc.and SrcL, SrcR<.sw, .uw, .not>
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| setc_and_32_90b4e93ef9d4 | L32 | 32 | 0x00002065 / 0xf8007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| setc_and_32_90b4e93ef9d4 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| setc_and_32_90b4e93ef9d4 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| setc_and_32_90b4e93ef9d4 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | encoded operand or control |
| SrcR | encoded operand or control |
| SrcRType | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/SETC.AND.asl -->
```asl
readonly func InstructionContractOperation_SETC_AND() => ScalarOperation
begin
    return ScalarOperation_SETC_AND;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/SETC.AND.asl -->
```asl
readonly func InstructionContractHandler_SETC_AND() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommitLogical;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `SETC.AND - Combine scalar comparison results and update the bundle commit condition.`
- **Semantic handler:** `ExecuteSetCommitLogical`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
