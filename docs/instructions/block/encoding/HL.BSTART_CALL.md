# HL.BSTART CALL

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

<!-- ASL-SOURCE: asl/block/encoding/HL.BSTART_CALL.asl -->

## Normative identity {#PTO-INST-BLOCK-HL-BSTART-CALL}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
HL.BSTART.CALL <br_label>, <rt_label>, ->ra
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_bstart_call_48_3c784c583c90 | HL48 | 48 | 0x501600000011 / 0xf83f0000007f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_bstart_call_48_3c784c583c90 | simm25 | 25 | signed | [{"instruction_lsb":7,"value_lsb":0,"width":25}] |
| hl_bstart_call_48_3c784c583c90 | uimm5 | 5 | unsigned | [{"instruction_lsb":38,"value_lsb":0,"width":5}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/encoding/HL.BSTART_CALL.asl -->
```asl
readonly func InstructionContractMatches_HL_BSTART_CALL(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_hl_bstart_call_48_3c784c583c90);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/encoding/HL.BSTART_CALL.asl -->
```asl
readonly func InstructionContractHandler_HL_BSTART_CALL() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
