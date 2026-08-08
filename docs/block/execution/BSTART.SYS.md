<!-- GENERATED FROM: asl/block/execution/BSTART.SYS.asl -->
# BSTART.SYS

**Normative ASL source:** `asl/block/execution/BSTART.SYS.asl`

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

## Normative identity {#PTO-INST-BLOCK-BSTART-SYS}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
BSTART.SYS FALL<, fixup_label>
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_sys_32_762d9d84a6d8 | L32 | 32 | 0x00001081 / 0x00007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_sys_32_762d9d84a6d8 | simm17 | 17 | signed | [{"instruction_lsb":15,"value_lsb":0,"width":17}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| simm17 | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.SYS.asl -->
```asl
readonly func InstructionContractMatches_BSTART_SYS(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_sys_32_762d9d84a6d8);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.SYS.asl -->
```asl
readonly func InstructionContractHandler_BSTART_SYS() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.`
- **Semantic handler:** `ExecuteBundleStart`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
