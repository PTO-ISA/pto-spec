# FENTRY

Atomically validates and creates a frame-template entry state.

<!-- ASL-SOURCE: asl/block/lifecycle/FENTRY.asl -->

## Assembly

```asm
FENTRY [RegSrc0 ~ RegSrcn], sp!, uimm
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| fentry_32_a47584ec13b6 | L32 | 32 | 0x00000041 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| fentry_32_a47584ec13b6 | SrcBegin | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| fentry_32_a47584ec13b6 | SrcEnd | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| fentry_32_a47584ec13b6 | uimm | 15 | unsigned | [{"instruction_lsb":25,"value_lsb":3,"width":7},{"instruction_lsb":7,"value_lsb":10,"width":5}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/lifecycle/FENTRY.asl -->
```asl
readonly func InstructionContractMatches_FENTRY(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_fentry_32_a47584ec13b6);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/lifecycle/FENTRY.asl -->
```asl
readonly func InstructionContractHandler_FENTRY() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteFrameEntry;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
