# BSTART.TEPL

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

<!-- ASL-SOURCE: asl/block/execution/BSTART.TEPL.asl -->

## Normative identity {#PTO-INST-BLOCK-BSTART-TEPL}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
BSTART.TEPL Mode, Function, DataType
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_tepl_32_d022db6dacb3 | L32 | 32 | 0x00019181 / 0x000fffff | [{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_tepl_32_d022db6dacb3 | DataType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| bstart_tepl_32_d022db6dacb3 | Mode | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |
| bstart_tepl_32_d022db6dacb3 | Function | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.TEPL.asl -->
```asl
readonly func InstructionContractMatches_BSTART_TEPL(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_tepl_32_d022db6dacb3);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.TEPL.asl -->
```asl
readonly func InstructionContractHandler_BSTART_TEPL() => CommandSemanticHandler
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
