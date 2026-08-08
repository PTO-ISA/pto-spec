<!-- GENERATED FROM: asl/scalar/bru/SETC.NEI.asl -->
# SETC.NEI

**Normative ASL source:** `asl/scalar/bru/SETC.NEI.asl`

SETC.NEI - Compare scalar operands and update the bundle commit condition.

## Normative identity {#PTO-INST-SCALAR-SETC-NEI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
setc.nei SrcL, simm
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| setc_nei_32_fa01e973ab76 | L32 | 32 | 0x00001075 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| setc_nei_32_fa01e973ab76 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| setc_nei_32_fa01e973ab76 | shamt | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| setc_nei_32_fa01e973ab76 | simm12 | 12 | signed | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | encoded operand or control |
| shamt | encoded operand or control |
| simm12 | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/SETC.NEI.asl -->
```asl
readonly func InstructionContractOperation_SETC_NEI() => ScalarOperation
begin
    return ScalarOperation_SETC_NEI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/SETC.NEI.asl -->
```asl
readonly func InstructionContractHandler_SETC_NEI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommit;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `SETC.NEI - Compare scalar operands and update the bundle commit condition.`
- **Semantic handler:** `ExecuteSetCommit`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
