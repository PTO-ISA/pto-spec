<!-- GENERATED FROM: asl/block/attributes/B.CATR.asl -->
# B.CATR

**Normative ASL source:** `asl/block/attributes/B.CATR.asl`

Latches bundle control, trap, atomic, ordering, and address-class attributes.

## Normative identity {#PTO-INST-BLOCK-B-CATR}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
B.CATR {trap, atomic, <aq, rl, aqrl>, far, dr}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| b_catr_32_e90bd52fa480 | L32 | 32 | 0x00000023 / 0xfbf07fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| b_catr_32_e90bd52fa480 | DR | 1 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":1}] |
| b_catr_32_e90bd52fa480 | trap | 1 | encoding-defined | [{"instruction_lsb":19,"value_lsb":0,"width":1}] |
| b_catr_32_e90bd52fa480 | far | 1 | encoding-defined | [{"instruction_lsb":18,"value_lsb":0,"width":1}] |
| b_catr_32_e90bd52fa480 | atom | 1 | encoding-defined | [{"instruction_lsb":17,"value_lsb":0,"width":1}] |
| b_catr_32_e90bd52fa480 | aq | 1 | encoding-defined | [{"instruction_lsb":16,"value_lsb":0,"width":1}] |
| b_catr_32_e90bd52fa480 | rl | 1 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":1}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| DR | encoded operand or control |
| trap | encoded operand or control |
| far | encoded operand or control |
| atom | encoded operand or control |
| aq | encoded operand or control |
| rl | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/attributes/B.CATR.asl -->
```asl
readonly func InstructionContractMatches_B_CATR(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_b_catr_32_e90bd52fa480);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/attributes/B.CATR.asl -->
```asl
readonly func InstructionContractHandler_B_CATR() => CommandSemanticHandler
begin
    return CommandHandler_SetBundleControlAttributes;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `Latches bundle control, trap, atomic, ordering, and address-class attributes.`
- **Semantic handler:** `SetBundleControlAttributes`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
