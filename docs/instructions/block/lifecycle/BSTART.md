# BSTART

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

<!-- ASL-SOURCE: asl/block/lifecycle/BSTART.asl -->

## Normative identity {#PTO-INST-BLOCK-BSTART}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
BSTART {DIRECT, CALL}, <label>
BSTART COND, <label>
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_32_7eb93b649748 | L32 | 32 | 0x00000011 / 0x0000007f | [] |
| bstart_32_e11e678a32ac | L32 | 32 | 0x00000021 / 0x0000007f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_32_7eb93b649748 | simm25 | 25 | signed | [{"instruction_lsb":7,"value_lsb":0,"width":25}] |
| bstart_32_e11e678a32ac | simm25 | 25 | signed | [{"instruction_lsb":7,"value_lsb":0,"width":25}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/lifecycle/BSTART.asl -->
```asl
readonly func InstructionContractMatches_BSTART(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_32_7eb93b649748) ||
           (operation == CommandOperation_bstart_32_e11e678a32ac);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/lifecycle/BSTART.asl -->
```asl
readonly func InstructionContractHandler_BSTART() => CommandSemanticHandler
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
