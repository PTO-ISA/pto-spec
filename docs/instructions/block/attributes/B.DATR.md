# B.DATR

Latches tile layout, data type, padding, conversion, rounding, and saturation attributes.

<!-- ASL-SOURCE: asl/block/attributes/B.DATR.asl -->

## Assembly

```asm
B.DATR {layout, datatype, padvalue_or_byteid, cmode, rmode, sat, canonicalize}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| b_datr_32_c161a042ff38 | L32 | 32 | 0x00001023 / 0x000c707f | [{"field":"CMode","operator":"one-of","values":[0,1,2,3,4,5]},{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]},{"field":"Layout","operator":"one-of","values":[0,1,3,4,6,8,9,17,18,20,27,28,30]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| b_datr_32_c161a042ff38 | CMode | 3 | encoding-defined | [{"instruction_lsb":29,"value_lsb":0,"width":3}] |
| b_datr_32_c161a042ff38 | PadValueOrByteId | 2 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":2}] |
| b_datr_32_c161a042ff38 | Sat | 1 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":1}] |
| b_datr_32_c161a042ff38 | Canonicalize | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |
| b_datr_32_c161a042ff38 | DataType | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| b_datr_32_c161a042ff38 | RMode | 3 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":3}] |
| b_datr_32_c161a042ff38 | Layout | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/attributes/B.DATR.asl -->
```asl
readonly func InstructionContractMatches_B_DATR(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_b_datr_32_c161a042ff38);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/attributes/B.DATR.asl -->
```asl
readonly func InstructionContractHandler_B_DATR() => CommandSemanticHandler
begin
    return CommandHandler_SetBundleDataAttributes;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
