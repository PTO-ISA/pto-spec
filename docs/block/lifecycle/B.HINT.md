<!-- GENERATED FROM: asl/block/lifecycle/B.HINT.asl -->
# B.HINT

**Normative ASL source:** `asl/block/lifecycle/B.HINT.asl`

Records non-functional branch, temperature, prefetch-size, or trace guidance.

## Normative identity {#PTO-INST-BLOCK-B-HINT}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
B.HINT {BR.{likely, unlikely}, TEMP.{hot, warm, cool, none}, PRFSIZE}
B.HINT TRACE.{begin, end}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| b_hint_32_69d942ff1583 | L32 | 32 | 0x00000033 / 0x00087fff | [] |
| b_hint_32_f7d01d734925 | L32 | 32 | 0x00001033 / 0xffff7fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| b_hint_32_69d942ff1583 | L/UL | 1 | encoding-defined | [{"instruction_lsb":16,"value_lsb":0,"width":1}] |
| b_hint_32_69d942ff1583 | V | 1 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":1}] |
| b_hint_32_69d942ff1583 | prefetch_size | 12 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |
| b_hint_32_69d942ff1583 | temp | 2 | encoding-defined | [{"instruction_lsb":17,"value_lsb":0,"width":2}] |
| b_hint_32_f7d01d734925 | B/E | 1 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":1}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/lifecycle/B.HINT.asl -->
```asl
readonly func InstructionContractMatches_B_HINT(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_b_hint_32_69d942ff1583) ||
           (operation == CommandOperation_b_hint_32_f7d01d734925);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/lifecycle/B.HINT.asl -->
```asl
readonly func InstructionContractHandler_B_HINT() => CommandSemanticHandler
begin
    return CommandHandler_SetBundleHint;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
