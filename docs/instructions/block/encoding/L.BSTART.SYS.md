# L.BSTART.SYS

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

<!-- ASL-SOURCE: asl/block/encoding/L.BSTART.SYS.asl -->

## Normative identity {#PTO-INST-BLOCK-L-BSTART-SYS}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
L.BSTART.SYS FALL<, fixup_label>
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| l_bstart_sys_64_919e576c79e4 | L64 | 32 | 0x0000000f / 0x0000007f | [] |
| l_bstart_sys_64_919e576c79e4 | L64 | 32 | 0x00001011 / 0x00007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| l_bstart_sys_64_919e576c79e4 | simm | 42 | signed | [{"instruction_lsb":7,"value_lsb":0,"width":25},{"instruction_lsb":47,"value_lsb":25,"width":17}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/encoding/L.BSTART.SYS.asl -->
```asl
readonly func InstructionContractMatches_L_BSTART_SYS(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_l_bstart_sys_64_919e576c79e4);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/encoding/L.BSTART.SYS.asl -->
```asl
readonly func InstructionContractHandler_L_BSTART_SYS() => CommandSemanticHandler
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
